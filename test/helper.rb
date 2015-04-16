require 'rubygems'
require 'yaml'
require 'test/unit'
begin
  require 'byebug'
rescue LoadError
end

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'mt940'
require 'mt940/customer_statement_message'
