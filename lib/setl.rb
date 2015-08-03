require_relative "setl/version"
require_relative "setl/template"
require_relative "setl/file"
require 'mustache'

module SETL
  # This is used to indicate when a source file is malformed.
  class FormatError < StandardError
  end

  # Given the contents of a SQL file with YAML front matter (see README for an
  # example) this will return a SETL::File object providing access to the parts
  # of that file.
  def self.parse(string, environment)
    raise ArgumentError, "The environment argument is required" unless environment
    File.new(string, environment).parse!
  end
end
