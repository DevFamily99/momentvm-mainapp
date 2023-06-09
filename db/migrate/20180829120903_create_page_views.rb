class CreatePageViews < ActiveRecord::Migration[5.2]
  def change
    create_table :page_views do |t|

    	t.integer :user_id
    	t.integer :page_id
      t.timestamps
    end
  end
end
