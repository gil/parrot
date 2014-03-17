nconf = require('nconf')

class Conf

  constructor: () ->
    nconf
      .argv()
      .env()

    environment = nconf.get("NODE_ENV") || "development"
    nconf.file(environment, "conf/" + environment + ".json")
    nconf.file("default", "conf/default.json")

  get: (key) ->
    nconf.get(key)

conf = new Conf()
module.exports = conf