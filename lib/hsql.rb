require_relative 'hsql/version'
require_relative 'hsql/template'
require_relative 'hsql/file'
require_relative 'hsql/query'
require 'mustache'

module HSQL
  # This is used to indicate when a source file is malformed.
  class FormatError < StandardError
  end

  # Given the contents of a SQL file with YAML front matter (see README for an
  # example) this will return a HSQL::File object providing access to the parts
  # of that file.
  def self.parse(string, environment)
    fail ArgumentError, 'The environment argument is required' unless environment
    File.new(string, environment).parse!
  end

  def self.parse_file(file, environment)
    parse(file.read, environment)
  end
end
