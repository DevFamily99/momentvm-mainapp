class UpdatePageContext < ActiveRecord::Migration[6.0]
  def change
    add_column :page_contexts, :preview_wrapper_url, :text
    add_column :page_contexts, :selector, :text
  end
end
