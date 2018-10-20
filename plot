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
  end

  def render!
    template.render(
      account_names: account.account_names,
      points: points
    )
  end

  private

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

  p.option :begin, '-b', '--begin', 'When to begin the chart'
  p.option :end, '-e', '--end', 'When to end the chart'

  p.action do |_, options|
    options[:query] = ARGV
    chart = LineChart.new(query: ARGV.join(' ')).render!
    puts chart
  end
end
