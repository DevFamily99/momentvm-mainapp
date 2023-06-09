class CreateTags < ActiveRecord::Migration[6.0] #:nodoc:
  def change
    create_table :tags do |t|
      t.string :name
      t.references :team, null: false, foreign_key: true

      t.timestamps
    end
    add_index :tags, [:name, :team_id], unique: true
  end
end
