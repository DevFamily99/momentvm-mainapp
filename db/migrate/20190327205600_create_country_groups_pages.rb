class CreateCountryGroupsPages < ActiveRecord::Migration[5.2]
  def change
    create_table :country_groups_pages do |t|
      t.references :page, foreign_key: true
      t.references :country_group, foreign_key: true

      t.timestamps
    end
  end
end
