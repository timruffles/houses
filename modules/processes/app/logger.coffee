module.exports = logger =
  DEBUG: 0
  INFO: 1
  WARN: 2
  ERROR: 3
  logLevel: 1
  log: (msg,level = logger.INFO) ->
    if level >= logger.logLevel
      console.log msg
["debug","info","warn","error"].forEach (level) ->
  logger[level] = (msg) ->
    logger.log msg, level

