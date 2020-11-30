# redis-pubsub-rpc

[![Build Status](https://img.shields.io/github/workflow/status/dimailn/redis-pubsub-rpc/CI?kill_cache=1)](https://github.com/dimailn/redis-pubsub-rpc/actions?query=workflow%3ACI)
[![Coverage Status](https://coveralls.io/repos/github/dimailn/redis-pubsub-rpc/badge.svg?branch=master&?kill_cache=1)](https://coveralls.io/github/dimailn/redis-pubsub-rpc?branch=master)


This library provide lightweight RPC layer over Redis Pub/Sub.

# Installation

```
npm install --save redis-pubsub-rpc
```

# Getting started

Register handler in server application

```javascript

import {Server} from 'redis-pubsub-rpc'

const server = new Server('redis://127.0.0.1:6379')

server.addHandler('string.uppercase', (message) => message.toUpperCase())

```

And call the method from a client

```javascript

import {Client} from 'redis-pubsub-rpc'

const client = new Client('redis://127.0.0.1:6379')

client.call('string.uppercase', ['text']).then(console.log) // Prints 'TEXT'

```

You may also specify serverId and communicate with many servers in one application

```javascript
// create server with id
const server = new Server('redis://127.0.0.1:6379', {
  serverId: 'worker-0',
  applicationName: 'example'
})

const client = new Client('redis://127.0.0.1:6379', {
  applicationName: 'example'
})

// and specify serverId in call invocation

client.call('string.uppercase', ['text'], 'worker-0')

```

If you need to remove handler

```javascript
server.removeHandler('string.uppercase')
```

To shutdown client and server call method ```quit()```

```javascript

client.quit()
server.quit()

```


