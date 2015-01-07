# this is a beautification wrapper around the low-level
# MT940.parse command. use it in order to make dealing with
# the data easier
class MT940

  class CustomerStatementMessage

    attr_reader :statement_lines

    def self.parse_file(file)
      self.parse(File.read(file))
    end

    def self.parse(data)
      messages = MT940.parse(data)
      messages.map { |msg| new(msg) }
    end

    def initialize(lines)
      @account = lines.find { |line| line.class == MT940::Account }
      @statement_lines = []
      lines.each_with_index do |line, i|
        next unless line.class == MT940::StatementLine
        ensure_is_info_line!(lines[i+1])
        @statement_lines << StatementLineBundle.new(lines[i], lines[i+1])
      end
    end

    def bank_code
      @account.bank_code
    end

    def account_number
      @account.account_number
    end

    private

    def ensure_is_info_line!(line)
      unless line.is_a?(MT940::StatementLineInformation)
        raise StandardError, "Unexpected Structure; expected StatementLineInformation, but was #{line.class}"
      end
    end

  end

  class StatementLineBundle

    METHOD_MAP = {
      :amount                   => :line,
      :funds_code               => :line,
      :value_date               => :line,
      :entry_date               => :line,
      :account_holder           => :info,
      :details                  => :info,
      :account_number           => :info,
      :bank_code                => :info,
      :code                     => :info,
      :transaction_description  => :info,
    }

    def initialize(statement_line, statement_line_info)
      @line, @info = statement_line, statement_line_info
    end

    def method_missing(method, *args, &block)
      super unless METHOD_MAP.has_key?(method)
      object = instance_variable_get("@#{METHOD_MAP[method.to_sym]}")
      object.send(method)
    end

  end

end
