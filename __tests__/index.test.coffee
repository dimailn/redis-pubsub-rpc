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

    client = new Client("redis://#{REDIS_HOST}:#{REDIS_PORT}", timeout: 1000)

    result = await client.call('string.uppercase', ['text'], 'worker-0')

    expect(result).toBe 'TEXT'

    expect(server.getServerId()).toBe 'worker-0'

    expect(client.call('string.uppercase', ['text'])).rejects.toEqual(new Error('RPC request timeout'))

    await client.quit()
    await server.quit()

  test 'application namespace', ->
    server = new Server("redis://#{REDIS_HOST}:#{REDIS_PORT}", applicationName: 'test')

    server.addHandler('string.uppercase', (message) => message.toUpperCase())

    client = new Client("redis://#{REDIS_HOST}:#{REDIS_PORT}", applicationName: 'test')
    clientInStdNamespace = new Client("redis://#{REDIS_HOST}:#{REDIS_PORT}", timeout: 1000)

    result = await client.call('string.uppercase', ['text'])

    expect(result).toBe 'TEXT'

    expect(clientInStdNamespace.call('string.uppercase', ['text'])).rejects.toEqual(new Error('RPC request timeout'))

    await client.quit()
    await clientInStdNamespace.quit()
    await server.quit()




  test 'remote call throws', ->
    server = new Server("redis://#{REDIS_HOST}:#{REDIS_PORT}", applicationName: 'test')

    server.addHandler('string.uppercase', (message) => throw new Error("Something error"))

    client = new Client("redis://#{REDIS_HOST}:#{REDIS_PORT}", applicationName: 'test')

    expect(client.call('string.uppercase', ['text'])).rejects.toEqual("Something error")

    await client.quit()
    await server.quit()

  test 'method not found', ->
    server = new Server("redis://#{REDIS_HOST}:#{REDIS_PORT}", applicationName: 'test')

    client = new Client("redis://#{REDIS_HOST}:#{REDIS_PORT}", applicationName: 'test')

    expect(client.call('string.uppercase', ['text'])).rejects.toEqual("Method not found")

    await client.quit()
    await server.quit()

  test 'server and client terminates successfully', ->
    server = new Server("redis://#{REDIS_HOST}:#{REDIS_PORT}", applicationName: 'test')

    client = new Client("redis://#{REDIS_HOST}:#{REDIS_PORT}", applicationName: 'test')

    await new Promise((resolve, reject) -> setTimeout(resolve, 2000))
    expect(client.quit()).resolves.toBeDefined()
    expect(server.quit()).resolves.toBeDefined()

  return
