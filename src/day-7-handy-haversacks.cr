require "option_parser"
require "benchmark"
require "string_scanner"

file_name = ""
benchmark = false

REGEX_SELF = /(?<color1>\w+) (?<color2>\w+) bags contain/
REGEX_CONTAIN = /( (?<amount>\d) (?<contain1>\w+) (?<contain2>\w+) bags?(,|.)| no other bags.)/

OptionParser.parse do |parser|
  parser.banner = "Welcome to Report Repair"

  parser.on "-f FILE", "--file=FILE", "Input file" do |file|
    file_name = file
  end
  parser.on "-b", "--benchmark", "Measure benchmarks" do
    benchmark = true
  end
  parser.on "-h", "--help", "Show help" do
    puts parser
    exit
  end
end

unless file_name.empty?
  data = File.read_lines(file_name)

  bag_list = [] of Bag
  data.each do |bag|
    bag_list << Bag.new(bag)
    bag_list[-1].print
  end

  result = 0
  puts result
end

class Bag
  @color = ""
  @contains = [] of Tuple(Int32, String)

  def initialize(input : String)
    # puts input
    s = StringScanner.new(input)
    if s.scan(REGEX_SELF)
      @color = s["color1"] + " " + s["color2"]
    end
    while s.scan(REGEX_CONTAIN) && s["amount"]?
      @contains << {s["amount"].to_i, s["contain1"] + " " + s["contain2"]}
    end
  end

  def print
    puts "#{@color} bags contains:"
    @contains.each do |contains|
      puts "#{contains[0]} #{contains[1]} bag"
    end
  end
end