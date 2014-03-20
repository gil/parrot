'use strict';

angular.module('app')
  .controller 'ChatController', ($scope, $rootScope, $sce, $location, $routeParams, AuthService, ChatService) ->

    $scope.user = {}
    $scope.roomName = $routeParams.room;
    $scope.room = {}

    AuthService.me()
      .success (user) ->

        $scope.user = user
        $scope.room = ChatService.getRoom( $scope.roomName )
        ChatService.join( $scope.roomName )

        $rootScope.$watch "pageFocused", (pageFocused) ->
          drawLastMessageLine() if not pageFocused

        $rootScope.$on "chatMessage", (e, msg) ->
          autoScroll() if shouldAutoScroll

        autoScroll()

      .error (message, code) ->
        $location.path("/login")

    $(".messages").on "scroll", (e) ->
      shouldAutoScroll = checkShouldAutoScroll()

    $scope.parseMessage = (msg) ->
      $sce.trustAsHtml(msg)

    $scope.messageKeyDown = (e) ->
      if e.keyCode == 13
        ChatService.sendMessage( $scope.message, $scope.roomName )
        e.preventDefault()
        $scope.message = ""

    checkShouldAutoScroll = () ->
      msgContainer = $(".messages");
      return msgContainer.scrollTop() + msgContainer.height() + 10 >= msgContainer[0].scrollHeight

    shouldAutoScroll = true
    autoScrollTimeout = null

    autoScroll = () ->
      clearTimeout(autoScrollTimeout)
      autoScrollTimeout = setTimeout () ->
        msgContainer = $(".messages");
        msgContainer.scrollTop( msgContainer[0].scrollHeight )
      , 200

    drawLastMessageLine = () ->
      for msg, index in $scope.room.messages
        msg.lastUnread = ( index == $scope.room.messages.length - 1 )
