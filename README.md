# redis-pubsub-rpc

This library provide lightweight RPC layer over Redis Pub/Sub.

# Installation

```
npm install --save redis-pubsub-rpc
```

# Getting started

Register handler in server application

```javascript

import {Server} from 'redis-pubsub-rpc'

server = new Server('127.0.0.1:6379')

server.addHandler('string.uppercase', (message) => message.toUpperCase())

```

And call the method from a client

```javascript

import {Client} from 'redis-pubsub-rpc'

client = new Client('127.0.0.1:6379')

client.call('string.uppercase', ['text']).then(console.log) // Prints 'TEXT'

```

You can also specify serverId and communicate with many servers in one application

```javascript
// create server with id
server = new Server('127.0.0.1:6379', {
  serverId: 'worker-0',
  applicationName: 'example'
})

// and specify serverId in call invocation

client.call('string.uppercase', ['text'], 'worker-0')

```



