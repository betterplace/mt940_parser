class MT940
  module Errors
    class MT940Error < StandardError; end

    class FieldNotImplementedError < MT940Error; end

    class ParseError < MT940Error; end

    class WrongLineFormatError < ParseError; end

    class InvalidAmountFormatError < ParseError; end

    class UnexpectedStructureError < ParseError; end
  end

  include Errors
end
