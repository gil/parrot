'use strict'

angular.module('app')
  .service 'ChatService', ($http, $rootScope, RoomService) ->

    $rootScope.roomData = {}
    $rootScope.pageFocused = true
    socket = null

    getRoom = (roomName) ->
      if !$rootScope.roomData[ roomName ]
        $rootScope.roomData[ roomName ] =
          name : roomName
          messages : []
          users : []
          joined : false

      $rootScope.roomData[ roomName ]

    addMessage = (msg) ->
      messages = getRoom(msg.room).messages
      lastMessage = _.last(messages)

      msg.message = preParseMessage(msg.message)

      if lastMessage and msg.from.id and lastMessage.from.id == msg.from.id and !lastMessage.lastUnread
        lastMessage.date = msg.date
        lastMessage.message += "<br/>" + msg.message;
      else
        messages.push msg

      $rootScope.$emit("chatMessage", msg)

      if !$rootScope.pageFocused
            unreadCount++
            updateUnreadCount()

    preParseMessage = (msg) ->
      url_pattern = /([a-z]([a-z]|\d|\+|-|\.)*):(\/\/(((([a-z]|\d|-|\.|_|~|[\x00A0-\xD7FF\xF900-\xFDCF\xFDF0-\xFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:)*@)?((\[(|(v[\da-f]{1,}\.(([a-z]|\d|-|\.|_|~)|[!\$&'\(\)\*\+,;=]|:)+))\])|((\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5]))|(([a-z]|\d|-|\.|_|~|[\x00A0-\xD7FF\xF900-\xFDCF\xFDF0-\xFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=])*)(:\d*)?)(\/(([a-z]|\d|-|\.|_|~|[\x00A0-\xD7FF\xF900-\xFDCF\xFDF0-\xFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)*)*|(\/((([a-z]|\d|-|\.|_|~|[\x00A0-\xD7FF\xF900-\xFDCF\xFDF0-\xFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)+(\/(([a-z]|\d|-|\.|_|~|[\x00A0-\xD7FF\xF900-\xFDCF\xFDF0-\xFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)*)*)?)|((([a-z]|\d|-|\.|_|~|[\x00A0-\xD7FF\xF900-\xFDCF\xFDF0-\xFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)+(\/(([a-z]|\d|-|\.|_|~|[\x00A0-\xD7FF\xF900-\xFDCF\xFDF0-\xFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)*)*)|((([a-z]|\d|-|\.|_|~|[\x00A0-\xD7FF\xF900-\xFDCF\xFDF0-\xFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)){0})(\?((([a-z]|\d|-|\.|_|~|[\x00A0-\xD7FF\xF900-\xFDCF\xFDF0-\xFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)|[\xE000-\xF8FF]|\/|\?)*)?(\#((([a-z]|\d|-|\.|_|~|[\x00A0-\xD7FF\xF900-\xFDCF\xFDF0-\xFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)|\/|\?)*)?/img

      # msg = msg.replace(url_pattern, "$&")
      msg = msg.replace url_pattern, (url) ->
        if url.match( /\.(jpg|jpeg|png|gif)$/i )
          return "<br/><img src='#{url}' /><br/>"

        return "<a href='#{url}' target='_blank'>#{url}</a>"

      msg = msg.replace(/\n/g, "<br/>")

    serverMessage = (msg, roomName) ->
      addMessage
        from :
          name : "Parrot"
          photo : "img/parrot_icon.jpg"
        message : msg
        date : new Date()
        room : roomName

    unreadCount = 0

    watchPageFocus = () ->
      $(window).on "blur", (e) ->
        $rootScope.$apply () ->
          $rootScope.pageFocused = false

      $(window).on "focus", (e) ->
        $rootScope.$apply () ->
          $rootScope.pageFocused = true
          unreadCount = 0
          updateUnreadCount()
          $(".message-text").focus()

    alternateCount = 0
    alternateInterval = null

    alternateTitle = () ->

      clearInterval( alternateInterval )
      alternateCount = 0

      alternateInterval = setInterval () ->
        if alternateCount < 6
          if document.title.indexOf("Parrot") > -1
            document.title = "(#{ unreadCount }) <--"
          else
            document.title = "(#{ unreadCount }) Parrot"

        alternateCount++

        if alternateCount > 20
          alternateCount = 0
      , 1000

    updateUnreadCount = () ->
      if unreadCount > 0
        document.title = "(#{ unreadCount }) Parrot";
        alternateTitle()
      else
        clearInterval( alternateInterval )
        document.title = "Parrot";

    #
    # Public API
    #

    listen: () ->
      socket = io.connect null,
        transports: ['websocket', 'htmlfile', 'xhr-multipart', 'xhr-polling', 'jsonp-polling']#, 'flashsocket']

      # socket.on 'connect', () ->
      #   console.log "connect"

      socket.on 'message', (msg) ->
        $rootScope.$apply () ->
          addMessage(msg)

      socket.on 'join', (data) ->
        $rootScope.$apply () ->
          room = getRoom(data.room)
          room.users.push(data.user)

          serverMessage( "Hey, <b>#{data.user.name}</b> have joined the room!", data.room )

      socket.on 'leave', (data) ->
        $rootScope.$apply () ->
          room = getRoom(data.room)
          currentUsers = room.users
          room.users = _.without( currentUsers, _.find(currentUsers, { 'id': data.user.id }) )
          serverMessage( "User <b>#{data.user.name}</b> have left the room!", data.room )

      watchPageFocus()

    join: (roomName) ->
      room = getRoom(roomName)
      if !room.joined
        RoomService.users(roomName)
          .success (users) ->
            room.users = users
            room.joined = true
            socket.emit "join", roomName

    sendMessage: (message, roomName) ->
      socket.emit "message",
        message : message
        room : roomName

    getRoom: getRoom
