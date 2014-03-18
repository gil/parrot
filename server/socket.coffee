connect = require('connect')
cookie = require('cookie')
socketio = require('socket.io')
Conf = require('./conf')

serverMessage = (msg) ->
  {
    from : {
      name : "Parrot"
      photo : "img/parrot_icon.jpg"
    }
    message : msg
    date : new Date()
  }

class Socket

  @configureServer: (server, sessionStore) ->

    io = socketio.listen(server)

    io.configure () ->
      io.set 'authorization', (handshakeData, accept) ->

        if handshakeData.headers.cookie

          sessionSecret = Conf.get("server:sessionSecret")
          handshakeData.cookie = cookie.parse(handshakeData.headers.cookie);
          sid = handshakeData.cookie['connect.sid']
          handshakeData.sessionID = connect.utils.parseSignedCookies(handshakeData.cookie, sessionSecret)['connect.sid']

          sessionStore.get handshakeData.sessionID, (err, session) ->
            if err
              return accept('Invalid session!', false)
            else if !session
              return accept('Session not found!', false)

            handshakeData.session = session
            accept(null, true)

        else
          return accept('No cookies found.', false)

    io.sockets.on 'connection', (socket) ->

      socket.on "join", (room) ->
        user = socket.handshake.session.passport?.user
        socket.join(room)

        if user
          socket.set("user", user)
          io.sockets.in(room).emit "message", serverMessage( "Hey, <b>#{user.name}</b> have joined the room!" )

      # socket.on "leave", (room) ->
      socket.on "disconnect", () ->
        rooms = io.sockets.manager.roomClients[socket.id]

        socket.get 'user', (err, user) ->
          for room, joined of rooms
            if user and room.length > 0 and joined
              io.sockets.in(room.substr(1)).emit "message", serverMessage( "User <b>#{user.name}</b> have left the room!" )

      socket.on "message", (msg) ->
        socket.get 'user', (err, user) ->
          if user
            msg.date = new Date()
            msg.from = user
            io.sockets.in(msg.room).emit "message", msg

module.exports = Socket