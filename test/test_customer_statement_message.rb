require_relative 'helper'


# $DEBUG = true
class TestCustomerStatementMessage < Test::Unit::TestCase

  def setup
    file = File.dirname(__FILE__) + "/fixtures/sepa_snippet.txt"
    messages = MT940::CustomerStatementMessage.parse_file(file)
    @message = messages.first
    @message_2 = messages.last
  end

  def test_it_should_know_the_bank_code
    assert_equal "50880050", @message.bank_code
  end

  def test_it_should_know_the_account_number
    assert_equal "0194787400888", @message.account_number
  end

  def test_it_should_have_statement_lines
    assert @message.statement_lines.respond_to?(:each)
    assert_equal 4, @message.statement_lines.size
  end

  def test_statement_lines_should_have_amount_info_credit
    line = @message.statement_lines.first
    assert_equal 5099005, line.amount
    assert_equal :credit, line.funds_code
  end

  def test_statement_lines_should_have_amount_info_debit
    line = @message_2.statement_lines.first
    assert_equal 8, line.amount
    assert_equal :debit, line.funds_code
  end

  def test_statement_lines_should_have_account_holder
    line = @message.statement_lines.first
    assert_equal "KARL\n        KAUFMANN", line.account_holder
  end

  def test_statement_lines_info_should_have_bank_code
    line = @message.statement_lines.first
    assert_equal "DRESDEFF508", line.bank_code
  end

  def test_statement_lines_info_should_have_account_number
    line = @message.statement_lines.first
    assert_equal "DE14508800500194785000", line.account_number
  end

  def test_statement_lines_should_have_details
    line = @message.statement_lines.first
    assert_equal "EREF+EndToEndId TFNR 22 004\n 00001\nSVWZ+Verw CTSc-01 BC-PPP TF\nNr 22 004", line.details
  end

  def test_statement_lines_should_have_an_entry_date
    line = @message.statement_lines.first
    assert_equal Date.parse("2007-09-04"), line.entry_date
  end

  def test_statement_lines_should_have_a_value_date
    line = @message.statement_lines.first
    assert_equal Date.parse("2007-09-07"), line.value_date
  end

  def test_parsing_the_file_should_return_two_message_objects
    file = File.dirname(__FILE__) + "/fixtures/sepa_snippet.txt"
    messages = MT940::CustomerStatementMessage.parse_file(file)
    assert_equal 2, messages.size
    assert_equal "0194787400888", messages[0].account_number
    assert_equal "0194791600888", messages[1].account_number
  end

  def test_parsing_a_file_with_broken_structure_should_raise_an_exception
    file = File.dirname(__FILE__) + "/fixtures/sepa_snippet_broken.txt"
    assert_raise(MT940::UnexpectedStructureError) do
      MT940::CustomerStatementMessage.parse_file(file)
    end
  end

  def test_should_raise_method_missing_when_asking_statement_lines_for_unknown_stuff
    file = File.dirname(__FILE__) + "/fixtures/sepa_snippet.txt"
    message = MT940::CustomerStatementMessage.parse_file(file).first
    assert_raise(NoMethodError) { message.statement_lines.first.foo  }
  end
end
