require 'helper'
require 'yaml'

# $DEBUG = true
class TestMt940 < Test::Unit::TestCase

  def read_mt940_data(file)
    MT940.parse(IO.read(file))
  end
  
  def test_it_should_parse_fixture_files_correctly
    Dir[File.dirname(__FILE__) + "/fixtures/*.txt"].each do |file|
      data = read_mt940_data(file)
      generated_structure_file = file.gsub(/.txt$/, ".yml")

      assert_equal IO.read(generated_structure_file), data.to_yaml
    end
  end
end
