require 'pry'
require_relative '../lib/hsql'

describe HSQL do
  let(:readme) { File.expand_path('../../README.md', __FILE__) }
  let(:sql_file_name) { 'well_formed' }
  let(:sql_file) { File.expand_path("../#{sql_file_name}.sql", __FILE__) }
  # Use the example in the README as the canonical test case.
  let(:file_contents) do
    File.readlines(readme).select do |line|
      line =~ /^    /
    end.map { |line| line.sub!(/^    /, '') }.compact.join
  end
  let(:environment) { 'development' }

  describe '.parse' do
    subject(:parse) { HSQL.parse(file_contents, environment) }

    context 'when using the example from the README' do
      it 'interpolates successfully' do
        expect(parse.yaml).to eql(
          'owner' => 'jackdanger',
          'schedule' => 'hourly',
          'data' => {
            'production' => {
              'output_table' => 'summaries',
              'update_condition' => nil,
            },
            'development' => {
              'output_table' => 'jackdanger_summaries',
              'update_condition' => 'WHERE 1 <> 1',
            },
          }
        )
        expect(parse.queries).to eql([
          "USE some_database;",
          "INSERT INTO jackdanger_summaries SELECT * FROM interesting_information;",
          "UPDATE summaries_performed SET complete = 1 WHERE 1 <> 1;",
        ])
      end
    end

    context 'when the front matter is missing' do
      let(:file_contents) do
        <<-SQL
USE some_database;
INSERT INTO {{{output_table}}} SELECT * FROM interesting_information;
UPDATE summaries_performed SET complete = 1 {{{update_condition}}};
SQL
      end

      it 'throws an error' do
        expect { parse }.to raise_error(HSQL::FormatError, /The YAML front matter is required/)
      end
    end

    context 'when the environment is not provided' do
      let(:environment) {}

      it 'throws an error' do
        expect { parse }.to raise_error(ArgumentError, "The environment argument is required")
      end
    end

    context 'when there are variables in the SQL not represented in front matter' do
      let(:file_contents) do
        <<-SQL
owner: jackdanger
schedule: hourly
data:
  development:
    # Note that 'table' is missing
  production:
    table: yours
  test:
    table: mine
---
USE some_database;
SELECT * from {{{table}}};
SQL
      end
      it 'throws an error' do
        expect { parse }.to raise_error(HSQL::FormatError, /"table" is not set in "development" environment/)
      end
    end

    context 'for the development environment' do
      let(:environment) { 'development' }
      it 'interpolates development variables' do
        expect(parse.queries.join).to match(/INSERT INTO jackdanger_summaries/)
      end
    end

    context 'for the production environment' do
      let(:environment) { 'production' }
      it 'interpolates production variables' do
        expect(parse.queries.join).to match(/INSERT INTO summaries/)
      end
    end
  end
end
