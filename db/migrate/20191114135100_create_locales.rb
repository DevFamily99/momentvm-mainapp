class CreateLocales < ActiveRecord::Migration[5.2]
  def change
    create_table :locales do |t|
      t.string :code
      t.string :name
      t.string :display_name
      t.string :display_country
      t.string :display_language
      t.boolean :default
      t.references :site, index: true, foreign_key: true
      t.timestamps
    end
  end
end
