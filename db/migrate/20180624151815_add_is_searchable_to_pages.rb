class AddIsSearchableToPages < ActiveRecord::Migration[5.2]
  def change
  	add_column :pages, :is_searchable, :boolean
  end
end
