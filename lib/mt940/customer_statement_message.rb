# this is a beautification wrapper around the low-level
# MT940.parse command. use it in order to make dealing with
# the data easier
class MT940
  class CustomerStatementMessage
    attr_reader :account, :statement_lines, :opening_balance, :closing_balance

    def self.parse_file(file)
      parse(File.read(file))
    end

    def self.parse(data)
      messages = MT940.parse(data)
      messages.map { |msg| new(msg) }
    end

    def initialize(lines)
      @account = select_by_type(lines, MT940::AccountIdentification)
      @opening_balance = select_by_type(lines, MT940::AccountBalance)
      @closing_balance = select_by_type(lines, MT940::ClosingBalance)
      @statement_lines = []
      lines.each_with_index do |line, i|
        next unless line.class == MT940::StatementLine

        ensure_is_info_line!(lines[i + 1])
        @statement_lines << StatementLineBundle.new(lines[i], lines[i + 1])
      end
    end

    def bank_code
      @account.bank_code
    end

    def account_number
      @account.account_number
    end

    def signature
      Digest::SHA256.hexdigest(opening_balance&.content.to_s + closing_balance&.content.to_s)
    end

    private

    def select_by_type(lines, line_klass)
      lines.select { |line| line.instance_of?(line_klass) }.first
    end

    def ensure_is_info_line!(line)
      return if line.is_a? MT940::StatementLineInformation

      raise Errors::UnexpectedStructureError,
            'Unexpected Structure; expected StatementLineInformation, ' \
            "but was #{line.class}"
    end
  end

  class StatementLineBundle
    METHOD_MAP = {
      amount: :line,
      funds_code: :line,
      value_date: :line,
      entry_date: :line,
      account_holder: :info,
      details: :info,
      account_number: :info,
      bank_code: :info,
      code: :info,
      transaction_description: :info
    }

    def initialize(statement_line, statement_line_info)
      @line = statement_line
      @info = statement_line_info
    end

    def method_missing(method, *args, &)
      super unless METHOD_MAP.has_key?(method)
      object = instance_variable_get("@#{METHOD_MAP[method.to_sym]}")
      object.send(method)
    end
  end
end
