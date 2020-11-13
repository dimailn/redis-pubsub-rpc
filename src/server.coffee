EventEmitter = require './event-emitter'
uuid = require 'uuid'
createRedis = require './create-redis'

module.exports = class Server extends EventEmitter
  constructor: (@redisUrl, @options = {}) ->
    super()

    @options.applicationName ||= 'app'

    @pubClient = createRedis(@redisUrl)
    @subClient = createRedis(@redisUrl)

    @handlers = {}

    @serverId = @options.serverId || uuid.v4()

    @subClient.on('message', (channel, message) =>
      message = JSON.parse(message)

      {methodName, clientId, params, uuid} = message

      handler = @handlers[methodName]

      response =
        if handler?
          try
            result = handler(...params)
            result = await result if result instanceof Promise
            {
              result
              uuid
            }
          catch error
            {
              error: error.message
              uuid
            }
        else
          {
            error: "Method not found: #{methodName}"
            uuid
          }


      @pubClient.publish("rpc:#{@options.applicationName}:response:#{clientId}", JSON.stringify(response))

    )

    @subClient.subscribe("rpc:#{@options.applicationName}:request:#{@serverId}")


  getServerId: -> @serverId

  addHandler: (methodName, handler) ->
    @handlers[methodName] = handler

  removeHandler: (methodName) ->
    @handlers[methodName] = undefined