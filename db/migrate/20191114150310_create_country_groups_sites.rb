class CreateCountryGroupsSites < ActiveRecord::Migration[5.2] #:nodoc:
  def change
    create_table :country_groups_sites do |t|
      t.references :country_group, foreign_key: true
      t.references :site, foreign_key: true
      t.timestamps
    end
  end
end
