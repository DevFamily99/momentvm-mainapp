class AddPreviewBodyToTemplate < ActiveRecord::Migration[6.0]
  def change
    add_column :templates, :preview_body, :text
  end
end
