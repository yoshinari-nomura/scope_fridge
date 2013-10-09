# -*- coding: utf-8 -*-

##
## form for scope_prototype
##  subject:
##
module ScopeFridge
  module ViewHelpers
    def scope_prototype_select_tag(name, model)
      options = [["", ""]]

      model.new_scope_fridge.each do |scope|
        options << [human_name(scope), scope.name]
      end

      select_tag(name, options_for_select(options))
    end

    def scope_prototype_table_tag(name, scopes)
      ret = []

      content_tag(:table) do
        scopes.each_with_index do |scope, i|
          ret << scope_prototype_tag_single("#{name}[#{i}]", scope)
        end
        raw ret.join("\n")
      end
    end

    private

    def scope_prototype_tag_single(name, scope)
      ret = []
      content_tag(:tr) do
        ret << hidden_field_tag("#{name}[model]", scope.model)
        ret << hidden_field_tag("#{name}[name]", scope.name)
        ret << content_tag(:td, check_box_tag("#{name}[enabled]", true, scope.enabled))
        ret << content_tag(:td, human_name(scope))

        val = scope.operator.blank? ? nil : scope.operator.to_sym
        ret << content_tag(:td,
                           select_tag("#{name}[operator]",
                            options_from_collection_for_select(scope.available_operators, :symbol, :name, val)))
        ret << content_tag(:td) do
          args = (scope.arguments || [])
          case scope.scope_type
          when :string
            text_field_tag("#{name}[arguments][]", args.join(" "))
          when :list
            select_tag("#{name}[arguments][]",
                       options_for_select(scope.available_arguments, scope.arguments),
                       :multiple => (args.length > 1 ? true : false))
          else
          end
        end
        raw ret.join("\n")
      end
    end

    # include ActiveSupport::Inflector

    def human_name(scope)
      t "scope_fridge.#{ActiveSupport::Inflector.underscore(scope.model)}.#{scope.name}"
    end
    ::ActionView::Base.send :include, self
  end # ViewHelpers
end # ScopeFridge
