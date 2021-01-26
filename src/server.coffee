EventEmitter = require './event-emitter'
uuid = require 'uuid'
createRedis = require './create-redis'
isCircular = require 'is-circular'

module.exports = class Server extends EventEmitter
  constructor: (@redisUrl, @options = {}) ->
    super()

    @options.applicationName ||= 'app'

    @pubClient = createRedis(@redisUrl)
    @subClient = createRedis(@redisUrl)

    @handlers = {}

    @serverId = @options.serverId || 'main'

    @subClient.on('message', (channel, message) =>
      message = JSON.parse(message)

      {methodName, clientId, params, uuid} = message

      handler = @handlers[methodName]

      response =
        if handler?
          try
            result = handler(...params)
            result = await result if result instanceof Promise

            if typeof result is 'object' && isCircular(result)
              {
                error: "Method #{methodName} with params #{params} returns object with circular dependency, serialization is not possible."
                uuid
              }
            else
              {
                result
                uuid
              }
          catch error
            console.log error
            {
              uuid
              error: try
                JSON.stringify(error, Object.getOwnPropertyNames(error))
              catch e
                throw e unless e.message.includes('Converting circular structure to JSON')
                error.message
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

  quit: ->
    Promise.all(
      [
        @pubClient.quit()
        @subClient.quit()
      ]
    )