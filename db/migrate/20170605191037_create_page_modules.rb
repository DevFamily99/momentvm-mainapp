class CreatePageModules < ActiveRecord::Migration[5.1]
  def change
    create_table :page_modules do |t|
      t.string :schedule
      t.string :rank
      t.references :page, foreign_key: true
      t.references :template, foreign_key: true
      t.text :body

      t.timestamps
    end
  end
end
