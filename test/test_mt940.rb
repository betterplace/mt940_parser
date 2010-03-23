require 'helper'
require 'yaml'

# $DEBUG = true
class TestMt940 < Test::Unit::TestCase
  should "parse fixture files correctly" do
    Dir[File.dirname(__FILE__) + "/fixtures/*.txt"].each do |mt940_file|
      mt94_data = MT940.parse(IO.read(mt940_file))
      generated_structure_file = mt940_file.gsub(/.txt$/, ".yml")

      # File.open(generated_structure_file, "w") do |f| f.write mt94_data.to_yaml end
      assert_equal IO.read(generated_structure_file), mt94_data.to_yaml
    end
  end
end
