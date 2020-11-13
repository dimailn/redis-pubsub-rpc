{v4} = require 'uuid'
EventEmitter = require './event-emitter'
createRedis = require './create-redis'

sleep = (ms) -> new Promise((r) -> setTimeout(r, ms))


module.exports = class Client extends EventEmitter
  constructor: (@redisUrl, @options = {}) ->
    super()

    @options.timeout ||= 5000
    @options.applicationName ||= 'app'

    @pubClient = createRedis(@redisUrl)
    @subClient = createRedis(@redisUrl)

    @clientId = v4()

    @subClient.on('message', (channel, message) =>
      message = JSON.parse(message)

      @$emit "rpc:response:#{message.uuid}", message
    )

    @subClient.subscribe("rpc:#{@options.applicationName}:response:#{@clientId}")

  call: (methodName, params = [], serverId = 'main') ->
    {clientId} = @
    uuid = v4()

    unsubscribe = null

    promise = Promise.race(
      [
        new Promise((resolve, reject) =>
          unsubscribe = @$on("rpc:response:#{uuid}", (message) =>
            {error, result} = message

            return reject(error) if error

            resolve(result)
          )
        )
        sleep(@options.timeout).then(-> throw new Error("RPC request timeout"))
      ]
    ).finally(unsubscribe)

    @pubClient.publish(
      "rpc:#{@options.applicationName}:request:#{serverId}"
      JSON.stringify(
        {
          methodName
          params
          uuid
          clientId
        }
      )
    )

    promise

