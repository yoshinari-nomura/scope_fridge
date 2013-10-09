# encoding: utf-8

module ScopeFridge
  module ScopePrototype
    class String < Base
      def self.available_operators
        [
          ScopeFridge::Operator.new('文字列含む', :like),
          ScopeFridge::Operator.new('含まない', :not_like)
        ]
      end
    end # class String
  end # module ScopePrototype
end # module ScopeFridge
