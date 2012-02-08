_.extend String::,
  classify: ->
    _.map(@split("_"), (chunk) ->
      chunk.ucfirst()
    ).join ""
  ucfirst: ->
    @slice(0, 1).toUpperCase() + @slice(1)

  camelize: ->
    classified = @classify()
    classified.slice(0, 1).toLowerCase() + classified.slice(1)

  underscore: ->
    @replace(/(?!^)[A-Z]/g, (str) ->
      "_" + str.toLowerCase()
    ).replace /^[A-Z]/, (str) ->
      str.toLowerCase()
