require 'mustache'
module SETL
  class Template < Struct.new(:input)
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
        tree.map { |token| extract_variable_names(token) }.compact.flatten
      end
    end

    def ast
      ::Mustache::Parser.new.compile(input)
    end
  end
end
