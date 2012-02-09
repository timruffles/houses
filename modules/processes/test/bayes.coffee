brain = require "brain"
assert = require "assert"
fs = require "fs"

bayes = new brain.BayesianClassifier
  thresholds:
    "prime-minister": 3 # higher threshold for spam
    "someone-else": 1 # 1 is default threshold for all categories
  def: "prime-minister" # category if can't classify


cameron = fs.readFileSync "cameron.txt", "utf8"
cameron = cameron.split("\n").filter((l)->  /^(t|f) (.*)/.test(l)).map (line) ->
  match = /^(t|f) (.*)/.exec(line)
  isDavid = match[1] == "t"
  [isDavid,match[2]]


cameron.forEach ([isDavidCameron,line]) ->
  category = if isDavidCameron then "prime-minister" else "someone-else"
  console.log "training #{line.substr(0,20)} as #{category}"
  bayes.train(line, category)

console.log "classified"
classify = fs.readFileSync "to_classify.txt", "utf8"
classify = classify.split("\n")
classify.forEach (line) ->
  category = bayes.classify line
  console.log("#{category}: #{line}")
