class CreatePageModulesPages < ActiveRecord::Migration[5.2]
  def change
    create_table :page_modules_pages do |t|
      t.references :page_module, foreign_key: true
      t.references :page, foreign_key: true
    end
  end
end
