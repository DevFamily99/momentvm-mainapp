class AddDescriptionToTemplates < ActiveRecord::Migration[5.2]
  def change
    add_column :templates, :description, :string
  end
end
