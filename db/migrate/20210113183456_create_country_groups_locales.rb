class CreateCountryGroupsLocales < ActiveRecord::Migration[6.0] # :nodoc:
  def change
    create_table :country_groups_locales do |t|
      t.references :country_group, null: false, foreign_key: true
      t.references :locale, null: false, foreign_key: true
    end
  end
end
