require 'yaml'
require_relative 'query'
require_relative 'data'
require_relative 'template'
module HSQL
  # HSQL::File parses the input file and provides reader methods to the hash of
  # YAML data from the front matter section and a list of the queries in the SQL
  # portion.
  class File
    attr_reader :string, :timestamp, :environment

    # This is used to indicate when a source file is malformed.
    class FormatError < StandardError
    end

    def initialize(string, options)
      @string = string
      @timestamp = options.fetch(:timestamp, Time.current)
      @environment = options[:environment]
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
        validate_environment_exists!

        hash = metadata['data'] || {}
        hash = hash[environment] || {} if environment
        hash.merge(Data.for_machines(timestamp))
      end
    end

    def validate_environment_exists!
      return unless environment
      return if metadata['data'].blank? || metadata['data'].key?(environment)
      fail ArgumentError, "The environment #{environment.inspect} is not specified"
    end

    def interpolate_data!
      template = Template.new(@sql)
      template.variable_names.each do |name|
        next if data.key?(name)

        if environment
          fail FormatError, "#{name.inspect} is not set in #{environment.inspect} environment"
        else
          fail FormatError, "#{name.inspect} is not set! Did you provide the right environment argument?"
        end
      end

      # Insert the `data:` section of YAML for the given environment into our SQL queries.
      @rendered_sql = template.render(data)
    end
  end
end
