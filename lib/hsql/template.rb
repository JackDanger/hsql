require 'mustache'
module HSQL
  # Given some SQL that may contain Mustache tags (e.g. {{{ variable }}} ),
  # accept a hash of data that interpolates each tag.
  # Throws an error if one of the tag names can't be found in the data.
  class Template
    attr_reader :input

    def initialize(input)
      @input = input
    end

    def variable_names
      extract_variable_names(ast).uniq
    end

    def render(hash)
      Mustache.render(input, hash)
    end

    private

    # See Mustache::Generator#compile! for reference code
    def extract_variable_names(tree)
      return unless tree.is_a?(Array)
      if tree[1] == :fetch
        tree.last.first
      else
        tree.map { |token| extract_variable_names(token) }.flatten.compact
      end
    end

    def ast
      ::Mustache::Parser.new.compile(input)
    end
  end
end
