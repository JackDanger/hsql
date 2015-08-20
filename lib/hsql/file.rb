# HSQL::File parses the input file and provides reader methods to the hash of
# YAML data from the front matter section and a list of the queries in the SQL
# portion.
require 'yaml'
require_relative 'query'
module HSQL
  class File < Struct.new(:string, :environment)
    def metadata
      @metadata ||= @front_matter ? ::YAML.load(@front_matter) : {}
    end

    def queries
      @queries ||= Query.parse(@rendered_sql)
    end

    def parse!
      split!
      interpolate_data!
      self
    end

    private

    def split!
      @split ||= begin
        top_half, divider, rest = string.partition(/^---$/)
        if divider.present?
          @front_matter, @sql = top_half, rest
        else # No divider found, therefore no YAML header
          @sql = top_half
        end
        true
      end
    end

    def data
      @data ||= begin
        if metadata['data']
          unless metadata['data'].key?(environment)
            fail ArgumentError, "The environment #{environment.inspect} is not specified"
          end
          metadata['data'][environment] || {}
        else
          {}
        end.merge(Template.calendar_moment_data(Time.current))
      end
    end

    def interpolate_data!
      template = Template.new(@sql)
      template.variable_names.each do |name|
        unless data.key?(name)
          fail FormatError, "#{name.inspect} is not set in #{environment.inspect} environment"
        end
      end

      # Insert the `data:` section of YAML for the given environment into our SQL queries.
      @rendered_sql = template.render(data)
    end
  end
end
