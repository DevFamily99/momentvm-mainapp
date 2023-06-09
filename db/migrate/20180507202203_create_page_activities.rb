class CreatePageActivities < ActiveRecord::Migration[5.1]
  def change
    create_table :page_activities do |t|
      t.references :user, foreign_key: true
      t.text :note
      t.string :activity_type
      t.references :page, foreign_key: true

      t.timestamps
    end
  end
end
