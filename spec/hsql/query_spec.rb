require_relative '../../lib/hsql/query'

RSpec.describe HSQL::Query do
  let(:first_query) do
    'INSERT INTO "table_a" (a, b) SELECT * FROM "table_b"'
  end
  let(:sql) do
    ''"
    #{first_query};
    SELECT COUNT(*) FROM users; -- extra comment
    UPDATE factories -- comment inlined inside query
      SET x = y -- second comment
      WHERE a = b;
    "''
  end

  describe '.parse' do
    subject(:parse) { HSQL::Query.parse(sql) }

    it 'properly understands the queries' do
      expect(parse.map(&:to_s)).to eql(
        [
          'INSERT INTO "table_a" (a, b) SELECT * FROM "table_b"',
          'SELECT count(*) FROM "users"',
          'UPDATE "factories" SET x = "y" WHERE "a" = "b"'
        ]
      )
    end
  end

  describe '#to_s' do
    subject(:to_s) { HSQL::Query.parse(sql).first.to_s }

    it { is_expected.to eq(first_query) }
  end

  describe '#to_sql' do
    subject(:to_s) { HSQL::Query.parse(sql).first.to_sql }

    it { is_expected.to eq(first_query) }
  end

  describe '#ast' do
    subject(:ast) { HSQL::Query.parse(sql).first.ast }

    it 'looks like an abstract syntax tree of a query' do
      expect(ast.keys).to eq(['INSERT INTO'])
      expect(ast.values.map(&:keys)).to eq([
                                             %w(relation cols selectStmt returningList withClause)
                                           ])
    end
  end
end
