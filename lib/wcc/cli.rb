require 'optparse'

module Wcc

  #
  # Class CLI provides set optional arguments, target files and standard input.
  #
  # @author iranakam <zcqozolput47djofoknd@gmail.com>
  #
  class CLI

    class OptionParser::NeedlessArgument

      #
      # This method does remove an equal from the error result.
      #
      #
      # @return [String] optional argument from which equal is removed
      # 
      def analyze
        args[0].split(/=/)[0]
      end
    end

    #
    # @!attribute [rw] options
    #   @return [Hash] defined options
    attr_accessor :options
    #
    # @!attribute [rw] files
    #   @return [Array] containing target files (File)
    attr_accessor :files
    #
    # @!attribute [rw] stdin
    #   @return [Array] containing target lines (String)
    attr_accessor :stdin

    #
    # This method does make CLI instance
    #
    # @param [Array] argument optional argument and target files and standard input
    # 
    def initialize(argument)
      begin
        exit if setting(argument) === 0
      rescue OptionParser::NeedlessArgument => error
        puts error.set_option(error.analyze, true), error.message
        exit
      rescue OptionParser::InvalidOption => error
        puts error.message
        exit
      end
    end

    #
    # This method does parse argument and defines option.
    #
    # @param [Array] argument optional argument and target files and standard input.
    #
    # @return [Void]
    # 
    def setting(argument)
      parser = OptionParser.new
      parser.banner = '"wcc" is wc simple clone.'
      return 0 if define_options(parser) === 0
      @files = parser.parse!(argument)
      begin
        @stdin = readlines if @files.empty?
      rescue Interrupt
        return 0
      end
    end

    #
    # This method does define option and setting parser.
    #
    # @param [OptionParser] parser OptionParser
    #
    # @return [OptionParser] OptionParser
    # 
    def define_options(parser)
      @options = {}
      parser.on('-l', '--lines', 'print the newline counts') do
        @options[:l] = true
      end
      parser.on('-c', '--bytes', 'print the byte counts') do
        @options[:c] = true
      end
      parser.on('-w', '--words', 'print the word counts') do
        @options[:w] = true
      end
      parser.on_tail('-h', '--help', 'display this help and exit') do
        puts parser
        return 0
      end
      parser.on_tail('-v', '--version', 'output version information and exit') do
        puts <<~USAGE
        #{$PROGRAM_NAME} 1.0.0
        Try `#{$PROGRAM_NAME} -h` for more information.
        USAGE
        return 0
      end
    end

    #
    # This method does execute counts up target and output results
    #
    # @return [Array] containing results of counting up (Hash)
    # 
    def execute
      if @files.empty?
        results = Counter.stdin(@stdin)
      else
        results = Counter.files(@files)
      end
      Printer.output(results, @options)
    end

  end

  #
  # Class Counter provides count the number of lines, words, and bytes
  # of the content of a given files or standard input.
  #
  # @author iranakam <zcqozolput47djofoknd@gmail.com>
  #
  class Counter

    #
    # This method does count the number of lines, words, and bytes of the target files
    #
    # @param [Array] containing target files (File)
    #
    # @return [Array] result of counting up
    # 
    def self.files(targets)
      results = []
      targets.each do |target|
        begin
          result = {}
          open(target, 'r') do |t|
            result = self.file(t)
          end
          result[:filepath] = target
          results.push(result)
        rescue StandardError => e
          puts e.message
          raise StandardError
        end
      end
      results
    end

    #
    # This method does count the number of lines, words, and bytes of the target STDIN
    #
    # @param [Array] target containing target lines (String)
    #
    # @return [Array] containing results of counting up (Hash)
    # 
    def self.stdin(target)
      results = []
      result = {c_count: 0, w_count: 0, l_count: 0}
      target.each do |line|
        result[:l_count] += 1
        result[:c_count] += line.bytesize
        result[:w_count] += line.split(/\s+/).reject{|w| w.empty?}.length
      end
      results.push(result)
    end

    #
    # This method does count the number of lines, words, and bytes of the target file
    #
    # @param [File] target file
    #
    # @return [Hash] result of counting up
    # 
    def self.file(target)
      result = {c_count: 0, w_count: 0, l_count: 0}
      while line = target.gets
        result[:l_count] += 1
        result[:c_count] += line.bytesize
        result[:w_count] += line.split(/\n/).join(' ').split(/\s/).length
      end
      result
    end

  end

  #
  # Class Printer provides outputs the result of Counter class according
  # to the contents of option arguments.
  #
  # @author iranakam <zcqozolput47djofoknd@gmail.com>
  #
  class Printer

    #
    # This method does output result of Counter class according
    # to the contents of option arguments.
    #
    # @param [Array] results containing results of counting up (Hash)
    # @param [Hash] options defined option
    #
    # @return [Array] containing results of counting up (Hash)
    # 
    def self.output(results, options)
      results.each do |result|
        lines = []
        lines.push(result[:l_count]) if options[:l]
        lines.push(result[:w_count]) if options[:w]
        lines.push(result[:c_count]) if options[:c]
        unless options[:l] || options[:c] || options[:w]
          lines = [result[:l_count], result[:w_count], result[:c_count]]
        end
        if result.has_key?(:filepath)
          lines.push(result[:filepath])
        end
        puts lines.join(' ')
      end
    end

  end

end
