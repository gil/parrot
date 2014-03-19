express = require('express')
http = require('http')
livereload = require('connect-livereload')
Conf = require('./conf')
Socket = require('./socket')
Auth = require('./auth')
sessionStore = new express.session.MemoryStore();

app = express()
server = http.createServer(app)
serverPort = Conf.get("server:port")
sessionSecret = Conf.get("server:sessionSecret")

# Configure server
# app.use(express.logger());
app.use(express.cookieParser())
app.use(express.urlencoded())
app.use(express.json())
app.use(express.session({ store: sessionStore, secret: sessionSecret, key: 'connect.sid' }))
Auth.configureApp(app)
Socket.configureServer(server, sessionStore)

# Routes
devMode = ( Conf.get("NODE_ENV") == "development" )

app.use(livereload({ port: Conf.get("server:liveReloadPort") })) if devMode
app.use('/', express.static(__dirname + '/../client'))
app.use('/', express.static(__dirname + '/../../client')) if devMode

app.get "/api/ping", (req, res) ->
  res.json(200, "pong! :]")

app.get "/api/room/:room/users", (req, res) ->
  res.json(200, Socket.usersInRoom( req.params.room ))

server.listen(serverPort)
module.exports = app