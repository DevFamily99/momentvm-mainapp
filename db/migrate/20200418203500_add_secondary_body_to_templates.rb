class AddSecondaryBodyToTemplates < ActiveRecord::Migration[6.0]
  def change
    add_column :templates, :secondary_body, :text, default: ''
  end
end
