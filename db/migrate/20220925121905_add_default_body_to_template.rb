class AddDefaultBodyToTemplate < ActiveRecord::Migration[6.0]
  def change
    add_column :templates, :default_body, :string
  end
end
