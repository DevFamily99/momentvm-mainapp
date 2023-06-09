class CreatePageComments < ActiveRecord::Migration[5.2]
  def change
    create_table :page_comments do |t|
      t.text :body
      t.references :user, foreign_key: true
      t.references :page, foreign_key: true

      t.timestamps
    end
  end
end
