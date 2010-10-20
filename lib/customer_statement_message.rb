# this is a beautification wrapper around the low-level
# MT940.parse command. use it in order to make dealing with 
# the data easier
class MT940

  class CustomerStatementMessage

    attr_reader :statement_lines

    def self.parse_file(file)
      string = File.read(file)
      messages = MT940.parse(string)
      messages.map { |msg| new(msg) }
    end
    
    def initialize(raw_mt940)
      @raw = raw_mt940
      @account = @raw.find { |line| line.class == MT940::Account }
      @statement_lines = []
      @raw.each_with_index do |line, i|
        next unless line.class == MT940::StatementLine
        @statement_lines << StatementLineBundle.new(@raw[i], @raw[i+1])
      end
    end

    def bank_code
      @account.bank_code
    end

    def account_number
      @account.account_number
    end

  end
  
  class StatementLineBundle

    METHOD_MAP = {
      :amount         => :line,
      :funds_code     => :line,
      :account_holder => :info,
      :details        => :info,
    }

    def initialize(statement_line, statement_line_info)
      @line, @info = statement_line, statement_line_info
    end

    def method_missing(method, *args, &block)
      object = instance_variable_get("@#{METHOD_MAP[method.to_sym]}")
      object.send(method)
    end

  end
  
end