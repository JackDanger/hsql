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
    attr_reader :string, :timestamp, :environment, :rendered_sql

    def initialize(string, options)
      @string = string
      @timestamp = options.fetch(:timestamp, Time.current)
      @environment = options[:environment]
      @verbose = options[:verbose]
    end

    # Given a SQL file with YAML front matter (see README for an
    # example) this will return a HSQL::File object providing access to
    # the parts of that file.
    def self.parse_file(filename, options)
      parse(::File.read(filename), options)
    end

    def self.parse(source, options)
      new(source, options).parse!
    end

    delegate :to_yaml, to: :metadata

    delegate :to_json, to: :metadata

    def metadata
      @metadata ||= begin
        hash = @front_matter ? ::YAML.load(@front_matter) : {}
        environments = hash.delete('environments') || {}
        hash.merge(environments[environment] || {})
      end
    end

    def queries
      @queries ||= Query.parse(@rendered_sql)
    end

    def parse!
      split!
      interpolate_metadata!
      self
    end

    private

    # Insert the `environments:` data for the given environment into our
    # SQL queries.
    def template_data
      @data ||= metadata.merge(Data.for_machines(timestamp))
    end

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

    def interpolate_metadata!
      @rendered_sql = Template.new(@sql, @verbose).render(template_data)
    end
  end
end
