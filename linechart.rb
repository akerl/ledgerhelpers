#!/usr/bin/env ruby

require 'date'
require 'erb'

class LineChart
  attr_reader :account_names, :start, :stop

  def initialize(params = {})
    @account_names = params[:accounts]
    @start = params[:start] || Date.today.prev_year
    @stop = params[:stop] || Date.today.next_month.next_month
  end

  def points
    @points ||= start.upto(stop).each_with_object({}) do |d, obj|
      obj[d] = account_names.map { |x| accounts[x][d] }
    end
  end

  def accounts
    @accounts ||= account_names.map do |name|
      res = `ledger reg --no-pager -D --format "%D %(to_int(total))\\n" '#{name}'`.lines
      raise("Failed to find transactions for #{name}") if res.empty?
      vals = res.map(&:split).map { |d, v| [Date.parse(d), v.to_i] }.to_h
      [name, vals]
    end.to_h
  end

  def render!
    template.result(binding)
  end

  def template
    @template ||= ERB.new(template_file, nil, '<>')
  end

  def template_file
    @template_file ||= File.read(template_file_path)
  end

  def template_file_path
    @template_file_path ||= File.join(
      File.dirname(__FILE__),
      'assets',
      'linechart.html.erb'
    )
  end
end

raise('Must provide account names') if ARGV.empty?

chart = LineChart.new(accounts: ARGV).render!
puts chart
