require 'mustache'
require 'active_support/time'
module HSQL
  class Template < Struct.new(:input)
    def variable_names
      extract_variable_names(ast).uniq
    end

    def render(hash)
      Mustache.render(input, hash)
    end

    def self.calendar_moment_data(time)
      Hash[calendar_moments(time).map { |name, value, documentation| [name, value.to_s.inspect] }]
    end

    # A set of template variables that are always available and defined in
    # relation to the provided time or date.
    # The structure is designed to make generating documentation easier.
    def self.calendar_moments(time)
      # Time ranges surrounding the moment provided.
      moment = time
      moments = [
        ['beginning_of_hour',    moment.beginning_of_hour,    'The first second of the hour'],
        ['beginning_of_day',     moment.beginning_of_day,     'The first second of the day'],
        ['beginning_of_week',    moment.beginning_of_week,    'The first second of the week'],
        ['beginning_of_month',   moment.beginning_of_month,   'The first second of the month'],
        ['beginning_of_quarter', moment.beginning_of_quarter, 'The first second of the quarter'],
        ['beginning_of_year',    moment.beginning_of_year,    'The first second of the year'],
        ['end_of_hour',          moment.end_of_hour,          'The last second of the hour'],
        ['end_of_day',           moment.end_of_day,           'The last second of the day'],
        ['end_of_week',          moment.end_of_week,          'The last second of the week'],
        ['end_of_month',         moment.end_of_month,         'The last second of the month'],
        ['end_of_quarter',       moment.end_of_quarter,       'The last second of the quarter'],
        ['end_of_year',          moment.end_of_year,          'The last second of the year'],
      ]

      # Time ranges immediately preceding the one in which `time` appears.
      moment = time - 1.hour
      moments += [
        ['beginning_of_previous_hour', moment.beginning_of_hour, 'The first second of the hour'],
        ['end_of_previous_hour',       moment.end_of_hour,       'The last second of the hour'],
      ]

      moment = time - 1.day
      moments += [
        ['beginning_of_previous_day',  moment.beginning_of_day, 'The first second of the day'],
        ['end_of_previous_day',        moment.end_of_day,       'The last second of the day'],
      ]

      moment = time - 1.week
      moments += [
        ['beginning_of_previous_week',  moment.beginning_of_week, 'The first second of the week'],
        ['end_of_previous_week',        moment.end_of_week,       'The last second of the week'],
      ]
      moment = time - 1.month
      moments += [
        ['beginning_of_previous_month',  moment.beginning_of_month, 'The first second of the month'],
        ['end_of_previous_month',        moment.end_of_month,       'The last second of the month'],
      ]
      moment = time - 3.months
      moments += [
        ['beginning_of_previous_quarter',  moment.beginning_of_quarter, 'The first second of the quarter'],
        ['end_of_previous_quarter',        moment.end_of_quarter,       'The last second of the quarter'],
      ]
      moment = time - 1.year
      moments += [
        ['beginning_of_previous_year',  moment.beginning_of_year, 'The first second of the year'],
        ['end_of_previous_year',        moment.end_of_year,       'The last second of the year'],
      ]
    end

    private

    # See Mustache::Generator#compile! for reference code
    def extract_variable_names(tree)
      return unless tree.is_a?(Array)
      if tree[1] == :fetch
        tree.last.first
      else
        tree.map { |token| extract_variable_names(token) }.compact.flatten
      end
    end

    def ast
      ::Mustache::Parser.new.compile(input)
    end
  end
end
