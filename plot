#!/usr/bin/env ruby

require_relative 'charts/accounts.rb'
require_relative 'charts/templates.rb'

require 'mercenary'

##
# Describes a line chart object
class LineChart
  def initialize(params = {})
    @query = params[:query]
    @start = params[:start] || Date.today.prev_year
    @stop = params[:stop] || Date.today.next_month.next_month
    @scrub = params[:scrub]
  end

  def render!
    p = @scrub ? scrubbed_points : points
    template.render(
      account_names: account.account_names,
      points: p
    )
  end

  private

  def scrubbed_points
    @scrubbed_points ||= points.map do |k, v|
      [k, v.map { |x| (x * 1000 / max).round }]
    end.to_h
  end

  def max
    @max ||= points.values.flatten.max
  end

  def points
    @points ||= account.account_totals.select do |k, _|
      k >= @start && k <= @stop
    end
  end

  def account
    @account ||= Charts::Accounts.new(query: @query)
  end

  def template
    @template ||= Charts::Template.new(name: 'linechart.html')
  end
end

Mercenary.program(:plot) do |p|
  p.syntax 'plot [options] ACCOUNT_QUERY'

  p.option :begin, '-b DATE', '--begin DATE', 'When to begin the chart'
  p.option :end, '-e DATE', '--end DATE', 'When to end the chart'
  p.option :scrub, '-s', '--scrub', 'Scrub the absolute numbers'

  p.action do |_, options|
    params = { query: ARGV.join(' ') }
    params[:start] = Date.parse(options[:begin]) if options[:begin]
    params[:stop] = Date.parse(options[:end]) if options[:end]
    params[:scrub] = options[:scrub]
    chart = LineChart.new(params).render!
    puts chart
  end
end
