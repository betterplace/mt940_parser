require_relative 'test_helper'
require 'yaml'

# $DEBUG = true
class TestMt940 < Test::Unit::TestCase

  def test_it_should_parse_fixture_files_correctly
    Dir[File.dirname(__FILE__) + "/fixtures/*.txt"].reject { |f| f =~ /sepa_snippet/ }.each do |file|
      data = MT940.parse(IO.read(file))

      generated_structure_file = file.gsub(/.txt$/, ".yml")

      assert_equal YAML::load_file(generated_structure_file).to_yaml, data.to_yaml
    end
  end

  def test_it_takes_any_encoding_and_returns_binary
    file =  File.dirname(__FILE__) + "/fixtures/with_binary_character.txt"
    binary_file = MT940.parse(IO.read(file).force_encoding("ISO-8859-15"))
    utf8_file = MT940.parse(IO.read(file).force_encoding("UTF-8"))
    [binary_file, utf8_file].each do |file|
      assert_equal file.last.last.reference.encoding.name, "UTF-8"
    end
  end

end
