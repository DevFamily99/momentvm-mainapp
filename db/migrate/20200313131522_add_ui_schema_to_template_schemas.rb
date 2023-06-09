class AddUiSchemaToTemplateSchemas < ActiveRecord::Migration[6.0]
  def change
    add_column :template_schemas, :ui_schema, :text
  end
end
