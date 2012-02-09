var assert, bayes, brain, cameron, classify, fs;

brain = require("brain");

assert = require("assert");

fs = require("fs");

bayes = new brain.BayesianClassifier({
  thresholds: {
    "prime-minister": 3,
    "someone-else": 1
  },
  def: "prime-minister"
});

cameron = fs.readFileSync("cameron.txt", "utf8");

cameron = cameron.split("\n").filter(function(l) {
  return /^(t|f) (.*)/.test(l);
}).map(function(line) {
  var isDavid, match;
  match = /^(t|f) (.*)/.exec(line);
  isDavid = match[1] === "t";
  return [isDavid, match[2]];
});

cameron.forEach(function(_arg) {
  var category, isDavidCameron, line;
  isDavidCameron = _arg[0], line = _arg[1];
  category = isDavidCameron ? "prime-minister" : "someone-else";
  console.log("training " + (line.substr(0, 20)) + " as " + category);
  return bayes.train(line, category);
});

console.log("classified");

classify = fs.readFileSync("to_classify.txt", "utf8");

classify = classify.split("\n");

classify.forEach(function(line) {
  var category;
  category = bayes.classify(line);
  return console.log("" + category + ": " + line);
});
