require './test/test_helper'
require 'wcc/cli'

#
# Class WccTest provides does integration test
#
# @todo Addition of non-normail test case and total refactoring
#
# @author iranakam <zcqozolput47djofoknd@gmail.com>
#
class WccTest < Minitest::Unit::TestCase
  def test_that_it_has_a_version_number
    refute_nil ::Wcc::VERSION
  end

  def setup
    @filepath_first = './test/fixture/sample1.txt'
    @filepath_second = './test/fixture/sample2.txt'
    open(@filepath_first) do |f|
      @stdin = f.read
    end
  end

  def test_define_all_options_and_input_a_file
    expected_options = {w: true, c: true, l: true}
    expected_files = [@filepath_first]

    cli = Wcc::CLI.new(['-w', '-c', '-l', @filepath_first])
    assert_equal expected_options, cli.options
    assert_equal expected_files, cli.files
    assert_nil cli.stdin

    expected_result = [{c_count: 1260, w_count: 180, l_count: 20, filepath: @filepath_first}]
    assert_equal expected_result, result = Wcc::Counter.files(cli.files)

    expected = <<~CASE01
    20 180 1260 ./test/fixture/sample1.txt
    CASE01
    assert_output(expected) do 
      Wcc::Printer.output(result, cli.options)
    end
  end

  def test_define_all_options_and_input_some_files
    expected_options = {w: true, c: true, l: true}
    expected_files = [@filepath_first, @filepath_second]

    cli = Wcc::CLI.new(['--words', '--bytes', '--lines', @filepath_first, @filepath_second])
    assert_equal expected_options, cli.options
    assert_equal expected_files, cli.files
    assert_nil cli.stdin

    expected_result = [
      {c_count: 1260, w_count: 180, l_count: 20, filepath: @filepath_first},
      {c_count: 2520, w_count: 360, l_count: 40, filepath: @filepath_second}
    ]
    assert_equal expected_result, result = Wcc::Counter.files(cli.files)

    expected = <<~CASE02
    20 180 1260 ./test/fixture/sample1.txt
    40 360 2520 ./test/fixture/sample2.txt
    CASE02
    assert_output(expected) do 
      Wcc::Printer.output(result, cli.options)
    end
  end

  def test_define_all_options_and_stdin
    expected_options = {w: true, c: true, l: true}
    expected_stdin = @stdin

    $stdin = StringIO.new(@stdin)
    cli = Wcc::CLI.new(['-w', '-c', '-l'])
    assert_equal expected_options, cli.options
    assert_empty cli.files
    assert_equal expected_stdin, cli.stdin.join('')

    expected_result = [{c_count: 1260, w_count: 180, l_count: 20}]
    assert_equal expected_result, result = Wcc::Counter.stdin(cli.stdin)

    expected = <<~CASE03
    20 180 1260
    CASE03
    assert_output(expected) do 
      Wcc::Printer.output(result, cli.options)
    end
  end

  def test_not_define_options_and_input_stdin
    expected_options = {}
    expected_stdin = @stdin

    $stdin = StringIO.new(@stdin)
    cli = Wcc::CLI.new([])
    assert_equal expected_options, cli.options
    assert_empty cli.files
    assert_equal expected_stdin, cli.stdin.join('')

    expected_result = [{c_count: 1260, w_count: 180, l_count: 20}]
    assert_equal expected_result, result = Wcc::Counter.stdin(cli.stdin)

    expected = <<~CASE04
    20 180 1260
    CASE04
    assert_output(expected) do 
      Wcc::Printer.output(result, cli.options)
    end
  end

end
