# frozen_string_literal: true

class CreatePageModuleRoleWhitelists < ActiveRecord::Migration[5.2]
  def change
    create_table :page_module_role_whitelists do |t|
      t.references :role
      t.references :page_module
      t.references :user
      t.timestamps
    end
  end
end
