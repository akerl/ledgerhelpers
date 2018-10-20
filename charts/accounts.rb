require 'date'
require 'open3'

module Charts
  ##
  # Helpers for accounts
  class Accounts
    attr_reader :query

    def initialize(params = {})
      @query = params[:query]
    end

    def account_names
      @account_names ||= run("accounts #{query}").split("\n")
    end

    def account_totals
      @account_totals ||= sum_account_totals
    end

    def first_date
      @first_date ||= account_changes.map { |_, v| v.keys.min }.min
    end

    def last_date
      @last_date ||= account_changes.map { |_, v| v.keys.max }.max
    end

    def account_changes
      @account_changes ||= account_names.map do |name|
        res = run("reg -D --format \"%D %(amount)\\n\" '#{name}'").lines
        vals = res.map(&:split).each_with_object(Hash.new { 0 }) do |item, obj|
          date = Date.parse(item.first)
          obj[date] = item.last.gsub(/[$,]/, '').to_f
        end
        [name, vals]
      end.to_h
    end

    def run(cmd)
      stdout, stderr, status = Open3.capture3("ledger #{cmd}")
      raise("Failed to run: #{cmd} / #{stderr}") unless status.success?

      stdout
    end

    private

    def sum_account_totals
      old = []
      first_date.upto(last_date).each_with_object({}) do |date, obj|
        new = account_names.each_with_index.map do |name, index|
          (account_changes[name][date] + (old[index] || 0)).round(2)
        end
        obj[date] = new
        old = new
      end
    end
  end
end
