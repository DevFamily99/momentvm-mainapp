class AddRenderingTemplateToPageContexts < ActiveRecord::Migration[5.2]
  def change
    add_column :page_contexts, :rendering_template, :string, index: true
  end
end
