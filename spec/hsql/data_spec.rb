require_relative '../../lib/hsql/data'
require 'timecop'

RSpec.describe HSQL::Data do
  before { Timecop.freeze }

  describe '.for_humans' do
    subject(:for_humans) { HSQL::Data.for_humans }

    it 'reads clearly' do
      expect(for_humans).to eq(<<-DOC.chomp)
    {{{now}}}                           The moment provided via --date or --timestamp (defaults to the current system time)
    {{{beginning_of_hour}}}             The first second of the hour
    {{{beginning_of_day}}}              The first second of the day
    {{{beginning_of_week}}}             The first second of the week
    {{{beginning_of_month}}}            The first second of the month
    {{{beginning_of_quarter}}}          The first second of the quarter
    {{{beginning_of_year}}}             The first second of the year
    {{{end_of_hour}}}                   The last second of the hour
    {{{end_of_day}}}                    The last second of the day
    {{{end_of_week}}}                   The last second of the week
    {{{end_of_month}}}                  The last second of the month
    {{{end_of_quarter}}}                The last second of the quarter
    {{{end_of_year}}}                   The last second of the year
    {{{beginning_of_previous_hour}}}    The first second of the previous hour
    {{{end_of_previous_hour}}}          The last second of the previous hour
    {{{beginning_of_previous_day}}}     The first second of the previous day
    {{{end_of_previous_day}}}           The last second of the previous day
    {{{beginning_of_previous_week}}}    The first second of the previous week
    {{{end_of_previous_week}}}          The last second of the previous week
    {{{beginning_of_previous_month}}}   The first second of the previous month
    {{{end_of_previous_month}}}         The last second of the previous month
    {{{beginning_of_previous_quarter}}} The first second of the previous quarter
    {{{end_of_previous_quarter}}}       The last second of the previous quarter
    {{{beginning_of_previous_year}}}    The first second of the previous year
    {{{end_of_previous_year}}}          The last second of the previous year
DOC
    end
  end

  describe '.for_machines' do
    subject(:for_machines) { HSQL::Data.for_machines(Time.current) }

    it 'assigns the right seconds' do
      expect(for_machines).to eq({
        'now'                           => Time.current,
        'beginning_of_hour'             => 1.hour.ago.end_of_hour + 1.second,
        'beginning_of_day'              => 1.day.ago.end_of_day + 1.second,
        'beginning_of_week'             => 1.week.ago.end_of_week + 1.second,
        'beginning_of_month'            => 1.month.ago.end_of_month + 1.second,
        'beginning_of_quarter'          => 3.months.ago.end_of_quarter + 1.second,
        'beginning_of_year'             => 1.year.ago.end_of_year + 1.second,

        'end_of_hour'                   => 1.hour.from_now.beginning_of_hour - 1.second,
        'end_of_day'                    => 1.day.from_now.beginning_of_day - 1.second,
        'end_of_week'                   => 1.week.from_now.beginning_of_week - 1.second,
        'end_of_month'                  => 1.month.from_now.beginning_of_month - 1.second,
        'end_of_quarter'                => 3.months.from_now.beginning_of_quarter - 1.second,
        'end_of_year'                   => 1.year.from_now.beginning_of_year - 1.second,

        'beginning_of_previous_hour'    => 2.hours.ago.end_of_hour + 1.second,
        'end_of_previous_hour'          => 1.hour.ago.end_of_hour,
        'beginning_of_previous_day'     => 2.days.ago.end_of_day + 1.second,
        'end_of_previous_day'           => 1.day.ago.end_of_day,
        'beginning_of_previous_week'    => 2.weeks.ago.end_of_week + 1.second,
        'end_of_previous_week'          => 1.week.ago.end_of_week,
        'beginning_of_previous_month'   => 2.months.ago.end_of_month + 1.second,
        'end_of_previous_month'         => 1.month.ago.end_of_month,
        'beginning_of_previous_quarter' => 6.months.ago.end_of_quarter + 1.second,
        'end_of_previous_quarter'       => 3.months.ago.end_of_quarter,
        'beginning_of_previous_year'    => 2.years.ago.end_of_year + 1.second,
        'end_of_previous_year'          => 1.year.ago.end_of_year,
      }.reduce({}) { |h, (k, v)| h.update k => "'#{v}'" })
    end
  end
end
