class CreateAssets < ActiveRecord::Migration[5.1]
  def change
    create_table :assets do |t|
      t.string :name
      #t.attachment :image # Uncommented because we moved to ActiveStorage

      t.timestamps
    end
  end
end
