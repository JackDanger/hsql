require 'mustache'
module HSQL
  # Given some SQL that may contain Mustache tags (e.g. {{{ variable }}} ),
  # accept a hash of data that interpolates each tag.
  # Throws an error if one of the tag names can't be found in the data.
  class Template
    attr_reader :input

    # This is used to indicate when a source file is malformed.
    class FormatError < StandardError
    end

    def initialize(input, verbose)
      @input = input
      @verbose = verbose
    end

    def render(hash)
      Mustache.raise_on_context_miss = true
      output = Mustache.render(input, hash)
      if @verbose
        STDERR.puts '-- Rendered SQL:'
        STDERR.puts output
      end
      output
    rescue Mustache::ContextMiss => e
      fail_with(e.message, hash.keys.sort)
    end

    private

    def fail_with(message, keys)
      # Pull the missing template tag out of the message
      tag = message.scan(/Can't find (\w+) in /).flatten.first
      message = "Missing variable {{{ #{tag} }}}. At this point in the template the available variables are:"
      message += "\n"
      message += keys.join(', ')
      fail FormatError, message
    end

    def ast
      ::Mustache::Parser.new.compile(input)
    end
  end
end
