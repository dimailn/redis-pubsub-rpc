import {Client, Server} from '../src/index'


REDIS_HOST = process.env.REDIS_HOST || '127.0.0.1'
REDIS_PORT = process.env.REDIS_PORT || 6379

describe 'redis-pubsub-rpc', ->
  test 'client to one server call', ->
    server = new Server("redis://#{REDIS_HOST}:#{REDIS_PORT}")

    server.addHandler('string.uppercase', (message) => message.toUpperCase())

    client = new Client("redis://#{REDIS_HOST}:#{REDIS_PORT}")

    result = await client.call('string.uppercase', ['text'])

    expect(result).toBe 'TEXT'

    await client.quit()
    await server.quit()


  test 'client to named server call', ->
    server = new Server("redis://#{REDIS_HOST}:#{REDIS_PORT}", serverId: 'worker-0')

    server.addHandler('string.uppercase', (message) => message.toUpperCase())

    client = new Client("redis://#{REDIS_HOST}:#{REDIS_PORT}")

    result = await client.call('string.uppercase', ['text'], 'worker-0')

    expect(result).toBe 'TEXT'

    await client.quit()
    await server.quit()


  return