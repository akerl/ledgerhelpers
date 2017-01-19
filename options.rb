#!/usr/bin/env ruby

require 'pry'
require 'yaml'
require 'date'
require 'English'

GRANTS_CONFIG = ARGV.shift

unless GRANTS_CONFIG
  puts "Usage: #{$PROGRAM_NAME} path/to/grants.yml"
  exit 1
end

GRANTS = YAML.safe_load(File.read(GRANTS_CONFIG))

Dir.chdir(File.dirname(GRANTS_CONFIG))

def parse_file(file, strike)
  File.readlines(file).map(&:split).map do |date, count, _, _|
    count = count.gsub(/[^\d]/, '').to_i
    [Date.strptime(date, '%m/%d/%Y'), count, count * strike.to_f]
  end
end

EVENTS = GRANTS.each_with_object({}) do |(file, strike), obj|
  grant_events = parse_file(file, strike)
  grant_events.each do |date, count, cost|
    obj[date] ||= [0, 0]
    obj[date][0] += count
    obj[date][1] += cost
  end
end.to_a.map(&:flatten).sort_by(&:first)

def print_row(type, profit, count, cost)
  type = type.to_s.capitalize
  profit = profit.round(2)
  cost = cost.round(2)
  puts "#{type} -- $#{profit} / #{count} shares / $#{cost} cost"
end

def condense(events, price)
  events.each_with_object([0, 0, 0]) do |item, acc|
    acc[0] += price * item[1] - item[2]
    acc[1] += item[1]
    acc[2] += item[2]
  end
end

def check(date, price)
  date = Date.parse(date) if date.is_a? String
  res = EVENTS.group_by { |x| x.first > date }
  res = res.map { |k, v| [k, condense(v, price)] }.to_h
  vested, lost = res.values_at(false, true)
  print_row(:vested, *vested) if vested
  print_row(:lost, *lost) if lost
end

puts 'Usage: check("2017/12/01", 8.00)'

# rubocop:disable Lint/Debugger
binding.pry
