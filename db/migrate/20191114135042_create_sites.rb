class CreateSites < ActiveRecord::Migration[5.2]
  def change
    create_table :sites do |t|
      t.string :name
      t.string :salesforce_id
      t.references :team, index: true, foreign_key: true
      t.timestamps
    end
  end
end
