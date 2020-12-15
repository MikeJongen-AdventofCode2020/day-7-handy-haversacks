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
  data.reverse.each do |bag|
    bag_list << Bag.new(bag)
  end

  bag_list.each do |bag|
    bag.set_bag(bag_list)
  end

  bag_to_search = "shiny gold"
  no_containers = 0
  bag_list.each do |bag|
    # bag.print
    if bag.contains(bag_to_search) 
      # puts bag.color
      no_containers += 1 
    end
  end

  puts no_containers - 1
end

class Bag
  getter color = ""
  @contains = [] of Tuple(Int32, String)
  @contains_bag = [] of Bag

  def initialize(input : String)
    s = StringScanner.new(input)
    if s.scan(REGEX_SELF)
      @color = s["color1"] + " " + s["color2"]
    end
    while s.scan(REGEX_CONTAIN) && s["amount"]?
      name = s["contain1"] + " " + s["contain2"]
      @contains << {s["amount"].to_i, name}
    end
  end

  def set_bag(list : Array(Bag))
    @contains.each do |bag|
      @contains_bag << get_bag(bag[1], list)
    end
  end

  def print
    puts "#{@color} bags contains:"
    @contains.each do |contains|
      puts "#{contains[0]} #{contains[1].color} bag"
    end
  end

  def contains(bag_name : String)
    return true if @color == bag_name
    @contains_bag.each do |bag|
      return true if bag.contains(bag_name)
    end
    return false
  end

  def get_bag(bag_name : String, list : Array(Bag))
    list.each do |bag|
      return bag if bag.color == bag_name
    end
    puts "failed"
    return Bag.new("")
  end
end