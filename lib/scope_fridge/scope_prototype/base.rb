# encoding: utf-8

module ScopeFridge
  module ScopePrototype
    class Base
      attr_reader :model, :name, :scope_type

      VALID_OPTIONS = [:target_column, :prepend_scope, :available_arguments, :available_operators]
      VALID_OPTIONS.each do |name|
        attr_reader name
      end

      def available_arguments
        if @available_arguments.is_a?(Proc)
          return @available_arguments.call
        end
        return @available_arguments # Array
      end

      def available_operators
        self.class.available_operators
      end

      ## factories

      def initialize(model, name, scope_type, options)
        @model, @name, @scope_type = model, name, scope_type
        options.each do |opt, val|
          instance_variable_set("@#{opt}", val) if VALID_OPTIONS.member?(opt)
        end
        self.freeze
      end

      def self.build(model, name, scope_type, options)
        case scope_type
        when :list
          sub = ScopeFridge::ScopePrototype::List
        when :string
          sub = ScopeFridge::ScopePrototype::String
        else
          raise "Type Mismatch."
        end
        return sub.new(model, name, scope_type, options)
      end

      def make_argument(args)
        case scope_type
        when :list
          return args
        when :string
          if args and args.is_a?(Array)
            arg = args.first
          else
            arg = args
          end
          return ('%' + arg.to_s.downcase.gsub(/([!%_])/, '!\1') + '%')
        else
          return args
        end
      end

      def make_condition(column, operator)
        con = @model.connection

        case operator.to_s.downcase.to_sym
        when :in
          proc = "#{column} IN (?)"
        when :not_in
          proc = "#{column} IS NULL OR #{column} NOT IN (?)"
        when :null
          proc = "#{column} IS NULL OR #{column} = ''"
        when :not_null
          proc = "#{column} IS NOT NULL AND #{column} <> ''"
        when :date_in
          proc = "#{column} >= '#{con.quoted_date(arg1)}' AND #{column} <  '#{con.quoted_date(arg1 + 1)}'"
        when :date_not_in
          proc = "#{column} <  '#{con.quoted_date(arg1)}' OR  #{column} >= '#{con.quoted_date(arg1 + 1)}'"
        when :date_gt
          proc = "#{column} >= '#{con.quoted_date(arg1)}'"
        when :date_lt
          proc = "#{column} <= '#{con.quoted_date(arg1)}'"
        when :gt
          proc = "#{column} > #{arg1}"
        when :lt
          proc = "#{column} < #{arg1}"
        when :like
          proc = "LOWER(#{column}) LIKE ? ESCAPE '!'"
        when :not_like
          proc = "LOWER(#{column}) NOT LIKE ? ESCAPE '!'"
        else
          proc = "#{column} #{operator} (?)"
          # raise "Error: Unsupported Operator: #{operator.inspect}."
        end
        return proc
      end

      private

      def quote_string(string)
        @model.connection.quote(string)
      end

      def quote_like(arg)
        return '%' + arg.to_s.downcase.gsub(/([!%_])/, '!\1') + '%'
      end

    end # class Base
  end # module ScopePrototype
end # module ScopeFridge
