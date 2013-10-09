module ScopeFridge
  class Fridge
    include Enumerable

    attr_reader :model

    def initialize(model = nil)
      @model = model
      @scopes = []
    end

    def each # for enumerable
      @scopes.each do |scope|
        yield(scope)
      end
    end

    def <<(scope)
      @scopes << scope
      return self
    end

    def find_scope(name)
      @scopes.find{|scope| name and scope.name == name.to_sym }
    end

    def update_attributes(params)
      params.each do |i, s|
        if (scope = find_scope(s[:name])) && s[:model].to_s == scope.model.to_s
          scope.update_attributes(s)
        end
      end
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
        q.pp(@scopes)
      end
      q.breakable
      q.text(">")
    end

    alias_method :inspect, :pretty_print_inspect

    ## make a concrete merged scope (ActiveRecord::Relation)
    def commit
      scope = self.model.scoped
      @scopes.each do |s|
        scope = scope.merge(s.commit) if s.enabled
      end
      return scope
    end
  end # class Fridge
end # module ScopeFridge
