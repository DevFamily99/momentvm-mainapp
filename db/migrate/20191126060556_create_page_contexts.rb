class CreatePageContexts < ActiveRecord::Migration[5.2]
  def change
    create_table :page_contexts do |t|
      t.references :team, foreign_key: true
      t.string :name
      t.string :context
      t.string :slot

      t.timestamps
    end
  end
end
