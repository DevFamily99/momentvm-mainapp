module PageModules
  # Removes the nested module id from the parent modules body
  class RemoveNestedModuleId < Actor
    input :parent_module, allow_nil: false
    input :nested_module, allow_nil: false

    output :parent_module

    def call
      new_body = parent_module.body.gsub(nested_module.id.to_s, "''")
      parent_module.update!(body: new_body)
      self.parent_module = parent_module
    end
  end
end
