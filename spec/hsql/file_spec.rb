# (The YAML literal needs it)
require_relative '../../lib/hsql/file'

describe HSQL::File do
  let(:readme) { ::File.expand_path('../../../README.md', __FILE__) }
  let(:file_contents) do
    <<-SQL
# filename: daily_summary.sql
owner: jackdanger
schedule: hourly
top_level: value
environments:
  production:
    output_table: summaries
    update_condition:
  development:
    output_table: jackdanger_summaries
    update_condition: WHERE 1 <> 1
---
INSERT INTO {{{output_table}}} SELECT * FROM interesting_information;
UPDATE summaries_performed SET complete = 1 {{{update_condition}}};
SQL
  end

  let(:environment) { 'development' }
  let(:options) { { environment: environment } }

  describe '.parse_file' do
    let(:file) do
      f = Tempfile.new('any-prefix')
      f.write file_contents
      f.seek 0
      f
    end
    subject(:parse_file) { HSQL::File.parse_file(file, options) }

    it 'sends the file contents to HSQL.parse' do
      expect(HSQL::File).to receive(:parse).with(file_contents, options)
      parse_file
    end
  end

  describe '.parse' do
    subject(:parse) { HSQL::File.parse(file_contents, options) }

    context 'when using the example from the README' do
      it 'interpolates successfully' do
        expect(parse.metadata).to eql(
          'owner' => 'jackdanger',
          'schedule' => 'hourly',
          'top_level' => 'value',
          'output_table' => 'jackdanger_summaries',
          'update_condition' => 'WHERE 1 <> 1',
        )
        expect(parse.queries.map(&:to_s)).to eql([
          'INSERT INTO "jackdanger_summaries" SELECT * FROM "interesting_information"',
          'UPDATE "summaries_performed" SET complete = 1 WHERE 1 <> 1',
        ])
      end
    end

    context 'when the front matter is missing' do
      let(:file_contents) do
        'INSERT INTO "some_table" SELECT * FROM "interesting_information"'
      end

      it 'throws an error' do
        expect(parse.queries.first.to_s).to eq(file_contents)
      end
    end

    context 'when there are variables in the SQL not represented in front matter' do
      let(:file_contents) do
        <<-SQL
owner: jackdanger
schedule: hourly
environments:
  development:
    # Note that 'table' is missing
  production:
    table: yours
  test:
    table: mine
---
SELECT * from {{{table}}};
SQL
      end

      it 'throws an error' do
        expect { parse }.to raise_error(
          HSQL::Template::FormatError,
          /Missing variable {{{ table }}}. At this point in the template the available variables are:/,
        )
      end
    end

    context 'for the development environment' do
      let(:environment) { 'development' }
      it 'interpolates development variables' do
        expect(parse.queries.map(&:to_s).join).to match(
          /INSERT INTO "jackdanger_summaries"/,
        )
      end
    end

    context 'for the production environment' do
      let(:environment) { 'production' }
      it 'interpolates production variables' do
        expect(parse.queries.map(&:to_s).join).to match(/INSERT INTO "summaries"/)
      end
    end
  end

  describe '#to_yaml' do
    let(:file) { HSQL::File.parse(file_contents, options) }
    subject(:to_yaml) { file.to_yaml }

    it { is_expected.to eq(<<-YAML) }
---
owner: jackdanger
schedule: hourly
top_level: value
output_table: jackdanger_summaries
update_condition: WHERE 1 <> 1
YAML
  end

  describe '#to_json' do
    let(:file) { HSQL::File.parse(file_contents, options) }
    subject(:to_yaml) { file.to_json }

    it { is_expected.to eq(JSON.parse(<<-YAML).to_json) }
{
    "owner": "jackdanger",
    "schedule": "hourly",
    "top_level": "value",
    "output_table": "jackdanger_summaries",
    "update_condition": "WHERE 1 <> 1"
}
YAML
  end

  describe 'rendering' do
    # Simply instantiating renders the file
    subject(:render) { HSQL::File.parse(file_contents, options) }

    it 'includes top-level data in data: key' do
      expect(Mustache).to receive(:render).with(anything, hash_including('top_level' => 'value'))
      render
    end
  end
end
