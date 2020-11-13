redis = require 'redis'
{ promisify } = require "util"

module.exports = (url) ->
  client = redis.createClient(url)

  OPERATIONS = [
    'set', 'get', 'setex', 'keys', 'del', 'mget', 'mset', 'on', 'subscribe', 'publish'
  ]

  async = {}

  OPERATIONS.forEach((oper) ->
    async[oper] = promisify(client[oper]).bind(client)
  )

  async




