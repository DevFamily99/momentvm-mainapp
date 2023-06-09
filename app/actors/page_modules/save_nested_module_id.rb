module PageModules
  # Saves the nested modules id in the parent modules body
  class SaveNestedModuleId < Actor
    input :parent_module, allow_nil: false
    input :nested_module, allow_nil: false
    input :field_id, allow_nil: false

    output :parent_module

    def call
      new_body = YAML.load(parent_module.body)
      new_body[field_id] = "nested::#{nested_module.id}::"
      parent_module.update!(body: new_body.to_yaml)
      self.parent_module = parent_module
    end
  end
end
