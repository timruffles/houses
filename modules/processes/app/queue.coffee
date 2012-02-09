logger = require "./logger"

class Queue extends require("events").EventEmitter
  constructor: (@redis,@queue) ->
    @subscriber = @redis.createClient()
    @consumer = @redis.createClient()
    @subscriber.subscribe "enqueued:#{@queue}"
    @subscribe.on "message", @get
    @get()
  get: =>
    @consumer.multi()
          .lpop(@queue)
          .llen()
          .exec (err, [item,length]) =>
            if err
              return logger.error "Queue error", err
            @emit "item", JSON.parse(item) if item
            logger.log "Queue '#{@queue}' has #{length} items"
            @get() if length > 0

module.exports = Queue
