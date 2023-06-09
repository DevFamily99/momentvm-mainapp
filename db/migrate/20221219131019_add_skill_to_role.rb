class AddSkillToRole < ActiveRecord::Migration[6.1]
  # Previously all these options where keys in a serialized body attribute
  # Now we are making this more clear by attaching that directly to the role
  def change
    add_column :roles, :can_create_pages, :boolean, null: false, default: false
    add_column :roles, :can_edit_pages, :boolean, null: false, default: false
    add_column :roles, :can_approve_pages, :boolean, null: false, default: false
    add_column :roles, :can_see_advanced_menu, :boolean, null: false, default: false
    add_column :roles, :can_edit_templates, :boolean, null: false, default: false
    add_column :roles, :can_see_language_preview, :boolean, null: false, default: false
    add_column :roles, :can_see_country_preview, :boolean, null: false, default: false
    add_column :roles, :can_unpublish_pages, :boolean, null: false, default: false
    add_column :roles, :can_publish_pages, :boolean, null: false, default: false
    add_column :roles, :can_edit_settings, :boolean, null: false, default: false
    add_column :roles, :can_see_settings, :boolean, null: false, default: false
    add_column :roles, :can_edit_all_modules_by_default, :boolean, null: false, default: false
    add_column :roles, :can_edit_module_permissions, :boolean, null: false, default: false
    add_column :roles, :can_copy_modules, :boolean, null: false, default: false
    add_column :roles, :can_duplicate_page, :boolean, null: false, default: false
  end
end
