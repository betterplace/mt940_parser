require 'mt940/version'
require 'mt940/errors'
require 'mt940/customer_statement_message'
require 'bigdecimal'
require 'bigdecimal/util'
require 'date'
require 'digest/sha2'

class MT940
  class Field
    attr_reader :modifier, :content

    DATE       = /(\d{2})(\d{2})(\d{2})/
    SHORT_DATE = /(\d{2})(\d{2})/

    class << self
      LINE = /^:(\d{2})(\w)?:(.*)$/

      def for(line)
        if line.match(LINE)
          number = ::Regexp.last_match(1)
          modifier = ::Regexp.last_match(2)
          content = ::Regexp.last_match(3)
          klass = {
            '20' => Job,
            '21' => Reference,
            '25' => AccountIdentification,
            '28' => Statement,
            '60' => AccountBalance,
            '61' => StatementLine,
            '62' => ClosingBalance,
            '64' => ValutaBalance,
            '65' => FutureValutaBalance,
            '86' => StatementLineInformation
          }.fetch(number) do
            raise Errors::FieldNotImplementedError, "Field #{number} is not implemented"
          end

          klass.new(modifier, content)
        else
          raise Errors::WrongLineFormatError,
                "Wrong line format does not match #{LINE.inspect}. Got: " \
                "#{line.dump[0...80]}#{'[...]' if line.dump.size > 80}"
        end
      end
    end

    def initialize(modifier, content)
      @modifier = modifier
      @content  = content
      parse_content(content)
    end

    private

    def parse_amount_in_cents(amount)
      amount =~ /\A(\d+)(,\d*)?\z/ or
        raise Errors::InvalidAmountFormatError, "invalid amount #{amount.inspect}"
      (100 * amount.sub(',', '.').sub(/\.\z/, '').to_d).floor
    end

    def parse_date(date)
      date.match(DATE)
      ::Date.new("20#{::Regexp.last_match(1)}".to_i, ::Regexp.last_match(2).to_i, ::Regexp.last_match(3).to_i)
    end

    def parse_entry_date(raw_entry_date, value_date)
      raw_entry_date.match(SHORT_DATE)
      entry_date = ::Date.new(value_date.year, ::Regexp.last_match(1).to_i, ::Regexp.last_match(2).to_i)
      raise 'Unhandled case: value date and entry date are in different years' unless entry_date.year == value_date.year

      entry_date
    end
  end

  # 20
  class Job < Field
    attr_reader :reference

    def parse_content(content)
      @reference = content
    end
  end

  # 21
  class Reference < Job
  end

  # 25
  class AccountIdentification < Field
    attr_reader :account_identifier

    CONTENT = /(.{1,35})/ # any 35 chars (35x from the docs)

    def parse_content(content)
      content.match(CONTENT)
      @account_identifier = ::Regexp.last_match(1)
    end

    # fail over to the old Account class
    def method_missing(method, *args, &)
      @fail_over_implementation ||= Account.new(@modifier, @content)
      value = @fail_over_implementation.send(method)
      warn '[DEPRECATION]:'
      warn "You used '#{method}' on the Account/AccountIdentification class"
      warn 'This field is not part of the MT940 specification but implementation specific'
      warn "Please use the 'account_identifier' and parse yourself."

      value
    end
  end

  # 25 - Legacy
  # This class is deprecated as it does not match the spec.
  class Account < Field
    attr_reader :bank_code, :account_number, :account_currency

    CONTENT = %r{^(.{8,11})/(\d{0,23})([A-Z]{3})?$}

    def parse_content(content)
      content.match(CONTENT)
      @bank_code = ::Regexp.last_match(1)
      @account_number = ::Regexp.last_match(2)
      @account_currency = ::Regexp.last_match(3)
    end
  end

  # 28
  class Statement < Field
    attr_reader :number, :sheet

    CONTENT = %r{^(0|(\d{5,5})/(\d{2,5}))$}

    def parse_content(content)
      content.match(CONTENT)
      if ::Regexp.last_match(1) == '0'
        @number = @sheet = 0
      else
        @number = ::Regexp.last_match(2).to_i
        @sheet = ::Regexp.last_match(3).to_i
      end
    end
  end

  # 60
  class AccountBalance < Field
    attr_reader :balance_type, :sign, :currency, :amount, :date

    CONTENT = /^(C|D)(\w{6})(\w{3})(\d{1,12},\d{0,2})$/

    def parse_content(content)
      content.match(CONTENT)

      @balance_type =
        case @modifier
        when 'F'
          :start
        when 'M'
          :intermediate
        end

      @sign =
        case ::Regexp.last_match(1)
        when 'C'
          :credit
        when 'D'
          :debit
        end

      raw_date  = ::Regexp.last_match(2)
      @currency = ::Regexp.last_match(3)
      @amount   = parse_amount_in_cents(::Regexp.last_match(4))

      @date =
        case raw_date
        when 'ALT', '0'
          nil
        when DATE
          ::Date.new("20#{::Regexp.last_match(1)}".to_i, ::Regexp.last_match(2).to_i, ::Regexp.last_match(3).to_i)
        end
    end
  end

  # 61
  class StatementLine < Field
    attr_reader :date, :entry_date, :funds_code, :amount, :swift_code, :reference, :transaction_description

    CONTENT = %r{^(\d{6})(\d{4})?(C|D|RC|RD)\D?(\d{1,12},\d{0,2})((?:N|F).{3})(NONREF|.{0,16})(?:$|//)(.*)}

    def parse_content(content)
      content.match(CONTENT)

      raw_date       = ::Regexp.last_match(1)
      raw_entry_date = ::Regexp.last_match(2)
      @funds_code =
        case ::Regexp.last_match(3)
        when 'C'
          :credit
        when 'D'
          :debit
        when 'RC'
          :return_credit
        when 'RD'
          :return_debit
        end

      @amount = parse_amount_in_cents(::Regexp.last_match(4))
      @swift_code = ::Regexp.last_match(5)
      @reference = ::Regexp.last_match(6)
      @transaction_description = ::Regexp.last_match(7)

      @date = parse_date(raw_date)
      @entry_date = parse_entry_date(raw_entry_date, @date) if raw_entry_date
    end

    def value_date
      @date
    end
  end

  # 62
  class ClosingBalance < AccountBalance
  end

  # 64
  class ValutaBalance < AccountBalance
  end

  # 65
  class FutureValutaBalance < AccountBalance
  end

  # 86
  class StatementLineInformation < Field
    attr_reader :code, :transaction_description, :prima_nota, :details, :bank_code, :account_number,
                :account_holder, :text_key_extension, :not_implemented_fields

    def parse_content(content)
      content.match(/^(\d{3})((.).*)$/)
      @code = ::Regexp.last_match(1).to_i

      details        = []
      account_holder = []

      if seperator = ::Regexp.last_match(3)
        sub_fields = ::Regexp.last_match(2).scan(
          /#{Regexp.escape(seperator)}(\d{2})([^#{Regexp.escape(seperator)}]*)/
        )

        sub_fields.each do |(code, content)|
          case code.to_i
          when 0
            @transaction_description = content
          when 10
            @prima_nota = content
          when 20..29, 60..63
            details << content
          when 30
            @bank_code = content
          when 31
            @account_number = content
          when 32..33
            account_holder << content
          when 34
            @text_key_extension = content
          else
            @not_implemented_fields ||= []
            @not_implemented_fields << [code, content]
            warn "code not implemented: code:#{code} content: #{content.inspect}" if $DEBUG
          end
        end
      end

      @details = details.join("\n")
      @account_holder = account_holder.join("\n")
    end
  end

  class << self
    def parse(text)
      new_text = text.encode('UTF-8').strip
      new_text << "\r\n" if new_text.end_with?('-')
      raw_sheets = new_text.split(/^-\s*\r\n/).map do |sheet|
        sheet.gsub(/\r\n(?!:\d{2}\w?:)/, '')
      end
      raw_sheets.map { |raw_sheet| parse_sheet(raw_sheet) }
    end

    private

    def parse_sheet(sheet)
      lines = sheet.split("\r\n")
      lines.reject { |line| line.empty? }.map { |line| Field.for(line) }
    end
  end
end
