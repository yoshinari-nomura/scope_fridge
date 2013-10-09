module ScopeFridge
  class Operator
    attr_accessor :name, :symbol
    def initialize(name, symbol)
      @name, @symbol = name, symbol
    end
  end
end
