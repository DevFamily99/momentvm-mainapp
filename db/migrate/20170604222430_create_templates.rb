class CreateTemplates < ActiveRecord::Migration[5.1]
  def change
    create_table :templates do |t|
      t.text :body
      t.string :name

      t.timestamps
    end
  end
end
