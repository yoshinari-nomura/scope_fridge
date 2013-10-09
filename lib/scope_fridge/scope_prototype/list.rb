# encoding: utf-8

module ScopeFridge
  module ScopePrototype
    class List < Base
      def self.available_operators
        [
          ScopeFridge::Operator.new('いずれかである', :in),
          ScopeFridge::Operator.new('いずれでもない', :not_in)
        ]
      end
    end # class List
  end # module ScopePrototype
end # module ScopeFridge
