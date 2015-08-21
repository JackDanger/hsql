# rubocop:disable Metrics/MethodLength, Metrics/AbcSize
require 'optparse'
require 'active_support/time'
require_relative 'data'
require_relative 'version'

module HSQL
  # Stuff that I'd rather not put directly into the executable goes here. This
  # makes it much easier to test.
  class CommandLine
    def initialize
      @options = {}
    end

    def options
      option_parser.parse!
      @options
    end

    def filename
      option_parser.parse!
      ARGV.first
    end

    def option_parser
      @option_parser ||= OptionParser.new do |opts|
        opts.banner = banner
        opts.on('-d DATE',
                '--date DATE',
                '--timestamp DATE', 'The time that the SQL will consider to be "{{{now}}}".') do |option|
          @options[:timestamp] = Time.parse(option) if option
        end
        opts.on('-e ENV',
                '--env ENV',
                'Which key of the YAML header "data:" key you want to interpolate.') do |option|
          @options[:environment] = option
        end
        opts.on('-y', '--yaml', 'Output just the metadata for this file as YAML') do |_option|
          @options[:meta_only] = 'yaml'
        end
        opts.on('-j', '--json', 'Output just the metadata for this file as JSON') do |_option|
          @options[:meta_only] = 'json'
        end
        opts.on('-v', '--verbose', 'Output debug information') do |_option|
          @options[:verbose] = true
        end
        opts.on_tail('-V', '--version', 'Show the current version of HSQL') do |_option|
          puts HSQL::VERSION
          exit 1
        end
        opts.on('-h', '--help', 'Show the full help documentation') do |_option|
          help
        end
      end
    end

    def banner
      <<-BANNER
Usage: #{File.basename(__FILE__)} file [environment]

Arguments
  file: Any *.sql file. If it has a YAML header (ending in three hyphens) the metadata will be processed;

Options
BANNER
    end

    def help
      <<-HELP
TEMPLATE

You can use the Mustache syntax (three curly braces) to interpolate any of your
'data' into your SQL. You specify the data in the YAML header like so:

    data:
      production:     # whatever you want to be interpolated into your SQL
        name: Alison  # when you pass 'production' as the environment argument
      development:
        name: Kailey
    ---
    SELECT * FROM users WHERE name = '{{{name}}}'


There are some common date values available to you at all times, without having
to be defined in the YAML header:

#{HSQL::Data.for_humans}

For more details, run:
  open https://github.com/JackDanger/hsql
HELP
    end
  end
end
