module.exports = class EventEmitter
  constructor: ->
    @listeners = {}

  $on: (eventName, listener) ->
    @listeners[eventName] ||= []
    @listeners[eventName].push(listener)

    => @$off(eventName, listener)

  $off: (eventName, listener) ->
    @listeners[eventName] ||= []
    @listeners[eventName] = @listeners[eventName].filter((persistedListener) -> listener != persistedListener)

  $emit: (eventName, data) ->
    @listeners[eventName]?.forEach((listener) ->
      listener(data)
    )