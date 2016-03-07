require_relative '../../lib/hsql/template'

RSpec.describe HSQL::Template do
  let(:input) do
    <<-MUSTACHE
SELECT * FROM {{{table1}}} WHERE {{{where}}} AND unsafe = "{{escaped_where}}";
{{#array_of_data}}
INSERT INTO summary_{{date}} SELECT * from summaries
{{#condition}}
  WHERE date = {{date}}
{{/condition}}
{{/array_of_data}}
;
MUSTACHE
  end
  let(:verbose) { false }
  let(:template) { HSQL::Template.new(input, verbose) }

  describe '#render' do
    let(:data) do
      {
        table1: 'the_table',
        where: 'name = "The Pope"',
        escaped_where: '"<unsafe; DROP TABLE bobby;>"',
        array_of_data: [
          {
            condition: true,
            date: '20220205'
          },
          {
            condition: true,
            date: '20220206'
          }
        ]
      }
    end
    subject(:render) { template.render(data) }

    it 'interpolates everything properly' do
      expect(render).to eql(<<-SQL)
SELECT * FROM the_table WHERE name = "The Pope" AND unsafe = "&quot;&lt;unsafe; DROP TABLE bobby;&gt;&quot;";
INSERT INTO summary_20220205 SELECT * from summaries
  WHERE date = 20220205
INSERT INTO summary_20220206 SELECT * from summaries
  WHERE date = 20220206
;
SQL
    end
  end
end
