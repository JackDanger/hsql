require 'active_support/time'
module HSQL
  module Data
    extend self

    # The internal API for reading this data and inserting it into queries.
    def for_machines(time)
      Hash[calendar_moments(time).map { |name, value, _documentation| [name, value.to_s.inspect] }]
    end

    # For presenting to users the possible template variables they can use.
    def for_humans
      values = calendar_moments(Time.current)
      for_screen = values.map do |name, _, description|
        ["{{{#{name}}}}", description]
      end
      width = for_screen.max_by { |name, _| name.size }.first.size

      for_screen.map do |name, documentation|
        "    #{name.ljust(width, ' ')} #{documentation}"
      end.join("\n")
    end

    private

    # A set of template variables that are always available and defined in
    # relation to the provided time or date.
    # The structure is designed to make generating documentation easier.
    def calendar_moments(time)
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
        ['beginning_of_previous_hour', moment.beginning_of_hour, 'The first second of the previous hour'],
        ['end_of_previous_hour',       moment.end_of_hour,       'The last second of the previous hour'],
      ]

      moment = time - 1.day
      moments += [
        ['beginning_of_previous_day',  moment.beginning_of_day, 'The first second of the previous day'],
        ['end_of_previous_day',        moment.end_of_day,       'The last second of the previous day'],
      ]

      moment = time - 1.week
      moments += [
        ['beginning_of_previous_week',  moment.beginning_of_week, 'The first second of the previous week'],
        ['end_of_previous_week',        moment.end_of_week,       'The last second of the previous week'],
      ]
      moment = time - 1.month
      moments += [
        ['beginning_of_previous_month',  moment.beginning_of_month, 'The first second of the previous month'],
        ['end_of_previous_month',        moment.end_of_month,       'The last second of the previous month'],
      ]
      moment = time - 3.months
      moments += [
        ['beginning_of_previous_quarter',  moment.beginning_of_quarter, 'The first second of the previous quarter'],
        ['end_of_previous_quarter',        moment.end_of_quarter,       'The last second of the previous quarter'],
      ]
      moment = time - 1.year
      moments += [
        ['beginning_of_previous_year',  moment.beginning_of_year, 'The first second of the previous year'],
        ['end_of_previous_year',        moment.end_of_year,       'The last second of the previous year'],
      ]
    end
  end
end
