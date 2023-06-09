module PageModules
  # Maps the body and template of the nested module to the parent for rendering and publishing
  # Outputs a
  class MapNestedModulesToParentsBody < Actor
    input :modules, allow_nil: false

    output :mapped_modules

    def call
      nested_modules = PageModule.where(page_module_id: modules.ids)
      p nested_modules
    end
  end
end
