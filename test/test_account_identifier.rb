require_relative 'test_helper'

class TestAccountIdentification < Test::Unit::TestCase
  def test_account_identifier
    acc_ident = MT940::AccountIdentification.new('','12345690')
    assert_equal '12345690', acc_ident.account_identifier
  end

  def test_account_identifier_gets_the_first_35_characters
    content = '1' * 40
    acc_ident = MT940::AccountIdentification.new('', content)
    assert_equal 35, acc_ident.account_identifier.length
  end

  def test_DEPRECATED_bank_code
    content = '123456789/987EUR'
    acc_ident = MT940::AccountIdentification.new('', content)
    assert_equal '123456789', acc_ident.bank_code
  end

  def test_DEPRECATED_account_number
    content = '123456789/987EUR'
    acc_ident = MT940::AccountIdentification.new('', content)
    assert_equal '987', acc_ident.account_number
  end

  def test_DEPRECATED_account_currency
    content = '123456789/987EUR'
    acc_ident = MT940::AccountIdentification.new('', content)
    assert_equal 'EUR', acc_ident.account_currency
  end
end
