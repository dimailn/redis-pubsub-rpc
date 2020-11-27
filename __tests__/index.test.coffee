import {Client, Server} from '../src/index'


describe 'redis-pubsub-rpc', ->
  test 'client to one server call', ->
    server = new Server('redis://127.0.0.1:6379')

    server.addHandler('string.uppercase', (message) => message.toUpperCase())

    client = new Client('redis://127.0.0.1:6379')

    result = await client.call('string.uppercase', ['text'])

    expect(result).toBe 'TEXT'

    await client.quit()
    await server.quit()


  test 'client to named server call', ->
    server = new Server('redis://127.0.0.1:6379', serverId: 'worker-0')

    server.addHandler('string.uppercase', (message) => message.toUpperCase())

    client = new Client('redis://127.0.0.1:6379')

    result = await client.call('string.uppercase', ['text'], 'worker-0')

    expect(result).toBe 'TEXT'

    await client.quit()
    await server.quit()


  return
