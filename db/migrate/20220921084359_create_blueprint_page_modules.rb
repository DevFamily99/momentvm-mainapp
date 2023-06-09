class CreateBlueprintPageModules < ActiveRecord::Migration[6.0]
  def change
    create_table :blueprint_page_modules do |t|
      t.belongs_to :blueprint
      t.belongs_to :page_module


      t.timestamps null: false
    end
  end
end
