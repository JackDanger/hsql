module HSQL
  class Query < Struct.new(:ast)
    # Returns a list of queries found in the source SQL
    def self.parse(source)
      # Splits on semicolons at the end of the line, eliding any comment that
      # might be there.
      # TODO: update sql-parser to parse the actual whole set of queries and
      # return multiple parsed objects.
      source.split(/;\ *$| -- .*$/).map { |sql| new(SQLPArser::Parser.parse(sql)) }
    end

    # Show the parsed query as SQL
    def to_s
      ast.to_sql
    end
  end
end
