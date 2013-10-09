# encoding: utf-8

require 'forwardable'

module ScopeFridge
  class Scope
    extend Forwardable
    # This Scope object is to be built from a ScopePrototype object.
    # So, Scope does only have a few instance variables suitable for serialization.
    attr_reader :name, :model
    attr_accessor :operator, :arguments, :enabled

    # for the YAML dumper. invoked in YAML.dump(obj)
    def to_yaml_properties
      # Some instance variables should not be serialized.
      # For example, serializing a Proc will be in vain.
      # This method can indicate the significant variables to YAML.
      ["@name", "@model", "@operator", "@arguments", "@enabled"]
    end

    ## for the YAML loader. invoked in YAML.load(str)
    def yaml_initialize(tag, val)
      # some instance variables are assumed to be loaded before this
      # method is invoked.  As for the other stuffs, should be copied
      # from like an original prototype oejbect.
      include_prototype
    end

    def marshal_dump
      [@name, @model, @operator, @arguments, @enabled]
    end

    def marshal_load(data)
      @name, @model, @operator, @arguments, @enabled = *data
      include_prototype
    end

    def_delegators :@prototype,
    :scope_type,
    :target_column,
    :prepend_scope,
    :available_arguments,
    :available_operators,
    :make_condition,
    :make_argument

    def initialize(model, name)
      @model, @name = model, name
      include_prototype
    end

    def commit(op = @operator, args = @arguments)
      s = apply_prepend_scope
      s = apply_operator(s, op)
      s = apply_arguments(s, args)
      return s
    end

    def update_attributes(params)
      @operator = params[:operator].to_sym if available_operators.map(&:symbol).member?(params[:operator].to_sym)
      @arguments = params[:arguments]
      @enabled = (params[:enabled].blank? ? false : true)
      return self
    end

    require 'pp'
    # called from pp
    def pretty_print(q)
      prefix = "#<#{self.class}:0x#{self.__id__.to_s(16)} "
      q.group(2, prefix) do
        q.breakable

        q.text("@model=#{model.name},")
        q.breakable

        %w{name scope_type operator arguments enabled}.each do |s|
          q.text("@#{s}=")
          q.pp self.send(s.to_sym)
          q.text(",")
          q.breakable
        end
      end
      q.text(">")
    end

    alias_method :inspect, :pretty_print_inspect

    private

    def apply_prepend_scope
      return prepend_scope.call if prepend_scope
      return model.scoped
    end

    def apply_operator(s, op)
      @operator = op
      return s unless op
      cond = make_condition(target_column, op)
      return lambda {|arg| s.scoped(:conditions => [cond, arg])}
    end

    def apply_arguments(s, args)
      @arguments = args
      return s unless args
      args = make_argument(args)
      return s.call(args)
    end

    def include_prototype(prototype = nil)
      if prototype
        @prototype = prototype
      else
        @prototype = @model.find_prototype_scope(@name)
      end
    end
  end # class Scope
end # module ScopeFridge
