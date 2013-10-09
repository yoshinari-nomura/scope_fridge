require 'scope_fridge/fridge'
require 'scope_fridge/operator'
require 'scope_fridge/scope'
require 'scope_fridge/scope_prototype'
require 'scope_fridge/view_helpers'

module ScopeFridge
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def refrigerate_scope(name, scope_type, options)
      @scope_fridge ||= ScopeFridge::Fridge.new(self)
      @scope_fridge << ScopeFridge::ScopePrototype::Base.build(self, name, scope_type, options)
    end

    def find_prototype_scope(name)
      @scope_fridge.find_scope(name)
    end

    def new_scope_fridge(params = nil)
      scopes = ScopeFridge::Fridge.new(self)
      @scope_fridge.each do |prototype|
        scopes << ScopeFridge::Scope.new(self, prototype.name)
      end
      if params
        return scopes.update_attributes(params)
      else
        return scopes
      end
    end
  end

  module InstanceMethods
  end

  send :include, ScopeFridge::InstanceMethods
end
ActiveRecord::Base.send(:include, ScopeFridge)
