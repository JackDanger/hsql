require 'yaml'
require 'json'
require_relative 'query'
require_relative 'data'
require_relative 'template'
module HSQL
  # HSQL::File parses the input file and provides reader methods to the hash of
  # YAML data from the front matter section and a list of the queries in the SQL
  # portion.
  class File
    attr_reader :string, :timestamp, :environment

    def initialize(string, options)
      @string = string
      @timestamp = options.fetch(:timestamp, Time.current)
      @environment = options[:environment]
      @verbose = options[:verbose]
    end

    # Given the contents of a SQL file with YAML front matter (see README for an
    # example) this will return a HSQL::File object providing access to the parts
    # of that file.
    def self.parse(string, options)
      new(string, options).parse!
    end

    def self.parse_file(file, options)
      parse(file.read, options)
    end

    def to_yaml
      metadata.to_yaml
    end

    def to_json
      metadata.to_json
    end

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
          @front_matter = top_half
          @sql = rest
        else # No divider found, therefore no YAML header
          @sql = top_half
        end
        true
      end
    end

    def data
      @data ||= begin
        hash = metadata['data'] || {}
        hash = hash.merge(hash[environment] || {})
        hash.merge(Data.for_machines(timestamp))
      end
    end

    def interpolate_data!
      # Insert the `data:` section of YAML for the given environment into our SQL queries.
      @rendered_sql = Template.new(@sql, @verbose).render(data)
    end
  end
end
