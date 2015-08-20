require_relative '../../lib/hsql/data'
require 'timecop'

RSpec.describe HSQL::Data do
  before { Timecop.freeze }

  describe '.for_humans' do
    subject(:for_humans) { HSQL::Data.for_humans }

    it "reads clearly" do
      expect(for_humans).to eq(<<-DOC.chomp)
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

    it "assigns the right seconds" do
      pending
    end
  end
end
