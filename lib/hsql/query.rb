require 'pg_query'
module HSQL
  class Query < Struct.new(:ast)
    # Returns a list of queries found in the source SQL
    def self.parse(source)
      # Splits on semicolons at the end of the line, eliding any comment that
      # might be there.
      PgQuery.parse(source).parsetree.map do |ast|
        Query.new(ast)
      end
    end

    # Show the parsed query as reconstructed SQL
    def to_s
      PgQuery.deparse ast
    end
    alias_method :to_sql, :to_s
  end
end
