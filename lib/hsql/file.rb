# HSQL::File parses the input file and provides reader methods to the hash of
# YAML data from the front matter section and a list of the queries in the SQL
# portion.
module HSQL
  class File < Struct.new(:string, :environment)
    def yaml
      @yaml ||= YAML.load(@front_matter)
    end

    def queries
      # TODO: allow multi-line queries!
      @queries ||= @rendered_sql.lines.map(&:chomp).reject(&:empty?)
    end

    def parse!
      split!
      interpolate_data!
      self
    end

    private

    def split!
      @split ||= begin
        @front_matter, divider, @sql = string.partition(/^---$/)
        unless divider == '---'
          raise FormatError, "The YAML front matter is required, otherwise this is just a SQL file"
        end
        true
      end
    end

    def data
      @data ||= begin
        if yaml['data']
          unless yaml['data'].key?(environment)
            raise ArgumentError, "The environment #{environment.inspect} is not specified"
          end
          yaml['data'][environment]
        end || {}
      end
    end

    def interpolate_data!
      template = Template.new(@sql)
      template.variable_names.each do |name|
        unless data.key?(name)
          raise FormatError, "#{name.inspect} is not set in #{environment.inspect} environment"
        end
      end

      # Insert the `data:` section of YAML for the given environment into our SQL queries.
      @rendered_sql = template.render(data)
    end
  end
end
