class CreateSettings < ActiveRecord::Migration[5.1]
  def change
    create_table :settings do |t|
      t.string :name
      t.text :body

      t.timestamps
    end
  end
end
