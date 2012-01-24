require "redis"
r = Redis.new
a = File.open("a","a+")
b = File.open("b","a+")
files = {"a" => a, "b" => b}
a_or_b = lambda do
  puts "\na or b? (or x to exit)"
  answer = gets.strip
  if answer =~ /^[ab]$/
    answer.strip
  elsif answer == "x"
    files.values.each(&:close) 
    puts "bye"
    exit
  else
    a_or_b.call
  end
end
data = STDIN.readlines
name = ARGV.shift
STDIN.reopen(File.open('/dev/tty', 'r'))
abort "No name set" unless name
set = "classified_#{name}" 
data.each do |line|
  unless r.sismember set, line
  puts "\n"
  puts line
  files[a_or_b.call].write line
  r.sadd set, line
end
end

