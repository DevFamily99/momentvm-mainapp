class AddAllowedCountriesToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :allowed_countries, :text
  end
end
