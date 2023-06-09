# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2022_12_19_131019) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "fuzzystrmatch"
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "asset_folders", force: :cascade do |t|
    t.string "name"
    t.bigint "asset_folder_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "team_id"
    t.string "slug"
    t.string "path"
    t.index ["asset_folder_id"], name: "index_asset_folders_on_asset_folder_id"
    t.index ["path"], name: "index_asset_folders_on_path", unique: true
    t.index ["slug"], name: "index_asset_folders_on_slug", unique: true
    t.index ["team_id"], name: "index_asset_folders_on_team_id"
  end

  create_table "assets", force: :cascade do |t|
    t.string "name"
    t.string "image_file_name"
    t.string "image_content_type"
    t.integer "image_file_size"
    t.datetime "image_updated_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "asset_folder_id"
    t.bigint "team_id"
    t.index ["asset_folder_id"], name: "index_assets_on_asset_folder_id"
    t.index ["team_id"], name: "index_assets_on_team_id"
  end

  create_table "blueprint_page_modules", force: :cascade do |t|
    t.bigint "blueprint_id"
    t.bigint "page_module_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["blueprint_id"], name: "index_blueprint_page_modules_on_blueprint_id"
    t.index ["page_module_id"], name: "index_blueprint_page_modules_on_page_module_id"
  end

  create_table "blueprints", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "country_groups", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "team_id"
    t.index ["team_id"], name: "index_country_groups_on_team_id"
  end

  create_table "country_groups_locales", force: :cascade do |t|
    t.bigint "country_group_id", null: false
    t.bigint "locale_id", null: false
    t.index ["country_group_id"], name: "index_country_groups_locales_on_country_group_id"
    t.index ["locale_id"], name: "index_country_groups_locales_on_locale_id"
  end

  create_table "country_groups_pages", force: :cascade do |t|
    t.bigint "page_id"
    t.bigint "country_group_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["country_group_id"], name: "index_country_groups_pages_on_country_group_id"
    t.index ["page_id"], name: "index_country_groups_pages_on_page_id"
  end

  create_table "country_groups_schedules", force: :cascade do |t|
    t.bigint "country_group_id"
    t.bigint "schedule_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["country_group_id"], name: "index_country_groups_schedules_on_country_group_id"
    t.index ["schedule_id"], name: "index_country_groups_schedules_on_schedule_id"
  end

  create_table "country_groups_sites", force: :cascade do |t|
    t.bigint "country_group_id"
    t.bigint "site_id"
    t.index ["country_group_id"], name: "index_country_groups_sites_on_country_group_id"
    t.index ["site_id"], name: "index_country_groups_sites_on_site_id"
  end

  create_table "customer_groups", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "team_id"
    t.index ["team_id"], name: "index_customer_groups_on_team_id"
  end

  create_table "customer_groups_schedules", force: :cascade do |t|
    t.bigint "customer_group_id"
    t.bigint "schedule_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["customer_group_id"], name: "index_customer_groups_schedules_on_customer_group_id"
    t.index ["schedule_id"], name: "index_customer_groups_schedules_on_schedule_id"
  end

  create_table "languages", force: :cascade do |t|
    t.string "code"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "locales", force: :cascade do |t|
    t.string "code"
    t.string "name"
    t.string "display_name"
    t.string "display_country"
    t.string "display_language"
    t.boolean "default"
    t.bigint "site_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["site_id"], name: "index_locales_on_site_id"
  end

  create_table "page_activities", force: :cascade do |t|
    t.bigint "user_id"
    t.text "note"
    t.string "activity_type"
    t.bigint "page_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "team_id"
    t.index ["page_id"], name: "index_page_activities_on_page_id"
    t.index ["team_id"], name: "index_page_activities_on_team_id"
    t.index ["user_id"], name: "index_page_activities_on_user_id"
  end

  create_table "page_comments", force: :cascade do |t|
    t.text "body"
    t.bigint "user_id"
    t.bigint "page_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["page_id"], name: "index_page_comments_on_page_id"
    t.index ["user_id"], name: "index_page_comments_on_user_id"
  end

  create_table "page_contexts", force: :cascade do |t|
    t.bigint "team_id"
    t.string "name"
    t.string "context"
    t.string "slot"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "rendering_template"
    t.text "preview_wrapper_url"
    t.text "selector"
    t.index ["team_id"], name: "index_page_contexts_on_team_id"
  end

  create_table "page_folders", force: :cascade do |t|
    t.string "name"
    t.bigint "page_folder_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_deleted"
    t.bigint "team_id"
    t.string "slug"
    t.string "path"
    t.index ["page_folder_id"], name: "index_page_folders_on_page_folder_id"
    t.index ["path"], name: "index_page_folders_on_path", unique: true
    t.index ["slug"], name: "index_page_folders_on_slug", unique: true
    t.index ["team_id"], name: "index_page_folders_on_team_id"
  end

  create_table "page_module_blacklists", force: :cascade do |t|
    t.bigint "page_module_id"
    t.bigint "country_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["country_id"], name: "index_page_module_blacklists_on_country_id"
    t.index ["page_module_id"], name: "index_page_module_blacklists_on_page_module_id"
  end

  create_table "page_module_role_blacklists", force: :cascade do |t|
    t.bigint "role_id"
    t.bigint "page_module_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["page_module_id"], name: "index_page_module_role_blacklists_on_page_module_id"
    t.index ["role_id"], name: "index_page_module_role_blacklists_on_role_id"
  end

  create_table "page_module_role_whitelists", force: :cascade do |t|
    t.bigint "role_id"
    t.bigint "page_module_id"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["page_module_id"], name: "index_page_module_role_whitelists_on_page_module_id"
    t.index ["role_id"], name: "index_page_module_role_whitelists_on_role_id"
    t.index ["user_id"], name: "index_page_module_role_whitelists_on_user_id"
  end

  create_table "page_modules", force: :cascade do |t|
    t.string "schedule"
    t.string "rank"
    t.bigint "template_id"
    t.text "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "team_id"
    t.bigint "page_module_id"
    t.index ["page_module_id"], name: "index_page_modules_on_page_module_id"
    t.index ["team_id"], name: "index_page_modules_on_team_id"
    t.index ["template_id"], name: "index_page_modules_on_template_id"
  end

  create_table "page_modules_pages", force: :cascade do |t|
    t.bigint "page_module_id"
    t.bigint "page_id"
    t.index ["page_id"], name: "index_page_modules_pages_on_page_id"
    t.index ["page_module_id"], name: "index_page_modules_pages_on_page_module_id"
  end

  create_table "page_modules_schedules", force: :cascade do |t|
    t.bigint "page_module_id"
    t.bigint "schedule_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["page_module_id"], name: "index_page_modules_schedules_on_page_module_id"
    t.index ["schedule_id"], name: "index_page_modules_schedules_on_schedule_id"
  end

  create_table "page_views", force: :cascade do |t|
    t.integer "user_id"
    t.integer "page_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "pages", force: :cascade do |t|
    t.string "context"
    t.string "schedule"
    t.string "context_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.text "locales_black_list"
    t.integer "translation_status"
    t.string "translation_key"
    t.text "folder_assignments"
    t.string "tag"
    t.bigint "page_folder_id"
    t.integer "title"
    t.integer "description"
    t.integer "keywords"
    t.integer "url"
    t.boolean "is_searchable"
    t.boolean "has_thumbnail"
    t.bigint "team_id"
    t.bigint "page_context_id"
    t.string "category"
    t.boolean "publish_assets"
    t.string "translation_project_id"
    t.integer "screenshot_status", default: 0
    t.string "publishing_folder"
    t.datetime "last_published"
    t.string "duplicated_from_page_link"
    t.datetime "duplicated_from_page"
    t.datetime "last_sent_to_translation"
    t.datetime "last_imported_translation"
    t.datetime "deleted_from_archive"
    t.index ["page_context_id"], name: "index_pages_on_page_context_id"
    t.index ["page_folder_id"], name: "index_pages_on_page_folder_id"
    t.index ["team_id"], name: "index_pages_on_team_id"
  end

  create_table "pg_search_documents", force: :cascade do |t|
    t.text "content"
    t.string "searchable_type"
    t.bigint "searchable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "team_id"
    t.index ["searchable_type", "searchable_id"], name: "index_pg_search_documents_on_searchable_type_and_searchable_id"
  end

  create_table "plans", force: :cascade do |t|
    t.string "name"
    t.integer "country_limit"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "publishing_events", force: :cascade do |t|
    t.bigint "publishing_manifest_id"
    t.string "category"
    t.text "message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "status"
    t.index ["publishing_manifest_id"], name: "index_publishing_events_on_publishing_manifest_id"
  end

  create_table "publishing_locales", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.string "locale"
    t.bigint "page_id"
    t.bigint "approver_id"
    t.index ["approver_id"], name: "index_publishing_locales_on_approver_id"
    t.index ["page_id"], name: "index_publishing_locales_on_page_id"
  end

  create_table "publishing_manifests", force: :cascade do |t|
    t.bigint "page_id"
    t.bigint "publishing_target_id"
    t.integer "progress_parts"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.bigint "schedule_id"
    t.boolean "publish_images"
    t.string "locale_codes"
    t.index ["page_id"], name: "index_publishing_manifests_on_page_id"
    t.index ["publishing_target_id"], name: "index_publishing_manifests_on_publishing_target_id"
    t.index ["schedule_id"], name: "index_publishing_manifests_on_schedule_id"
    t.index ["user_id"], name: "index_publishing_manifests_on_user_id"
  end

  create_table "publishing_manifests_sites", force: :cascade do |t|
    t.bigint "site_id"
    t.bigint "publishing_manifest_id"
    t.index ["publishing_manifest_id"], name: "index_publishing_manifests_sites_on_publishing_manifest_id"
    t.index ["site_id"], name: "index_publishing_manifests_sites_on_site_id"
  end

  create_table "publishing_targets", force: :cascade do |t|
    t.string "name"
    t.string "publishing_url"
    t.string "encrypted_webdav_username"
    t.string "encrypted_webdav_password"
    t.string "webdav_path"
    t.string "preview_url"
    t.bigint "team_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "default_library"
    t.string "catalog"
    t.string "encrypted_webdav_username_iv"
    t.string "encrypted_webdav_password_iv"
    t.index ["team_id"], name: "index_publishing_targets_on_team_id"
  end

  create_table "roles", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.text "body"
    t.bigint "team_id"
    t.boolean "can_create_pages", default: false, null: false
    t.boolean "can_edit_pages", default: false, null: false
    t.boolean "can_approve_pages", default: false, null: false
    t.boolean "can_see_advanced_menu", default: false, null: false
    t.boolean "can_edit_templates", default: false, null: false
    t.boolean "can_see_language_preview", default: false, null: false
    t.boolean "can_see_country_preview", default: false, null: false
    t.boolean "can_unpublish_pages", default: false, null: false
    t.boolean "can_publish_pages", default: false, null: false
    t.boolean "can_edit_settings", default: false, null: false
    t.boolean "can_see_settings", default: false, null: false
    t.boolean "can_edit_all_modules_by_default", default: false, null: false
    t.boolean "can_edit_module_permissions", default: false, null: false
    t.boolean "can_copy_modules", default: false, null: false
    t.boolean "can_duplicate_page", default: false, null: false
    t.index ["team_id"], name: "index_roles_on_team_id"
  end

  create_table "roles_users", id: false, force: :cascade do |t|
    t.integer "role_id"
    t.integer "user_id"
  end

  create_table "sales_force_configs", force: :cascade do |t|
    t.string "content_library"
    t.text "template"
    t.bigint "team_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["team_id"], name: "index_sales_force_configs_on_team_id"
  end

  create_table "schedules", force: :cascade do |t|
    t.datetime "start_at"
    t.datetime "end_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "published", default: false
    t.bigint "page_id"
    t.integer "screenshot_status", default: 0
    t.string "campaign_id"
    t.index ["page_id"], name: "index_schedules_on_page_id"
  end

  create_table "settings", force: :cascade do |t|
    t.string "name"
    t.text "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "team_id"
    t.index ["team_id"], name: "index_settings_on_team_id"
  end

  create_table "site_groups", force: :cascade do |t|
    t.string "library"
    t.string "sites"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sites", force: :cascade do |t|
    t.string "name"
    t.string "salesforce_id"
    t.bigint "team_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["team_id"], name: "index_sites_on_team_id"
  end

  create_table "tags", force: :cascade do |t|
    t.string "name"
    t.bigint "team_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["name", "team_id"], name: "index_tags_on_name_and_team_id", unique: true
    t.index ["team_id"], name: "index_tags_on_team_id"
  end

  create_table "teams", force: :cascade do |t|
    t.string "owner_firstname"
    t.string "owner_lastname"
    t.string "owner_email"
    t.string "name"
    t.boolean "approved", default: false
    t.string "encrypted_client_id"
    t.string "encrypted_client_secret"
    t.string "preview_wrapper_url"
    t.string "selector"
    t.string "encrypted_client_id_iv"
    t.string "encrypted_client_secret_iv"
    t.boolean "first_time_setup", default: false
    t.string "slug"
    t.integer "plan_id"
    t.boolean "show_setup_assistant", default: false
    t.string "initials"
    t.datetime "created_at", precision: 6, default: "2020-03-12 18:09:38", null: false
    t.datetime "updated_at", precision: 6, default: "2020-03-12 18:09:38", null: false
    t.string "translation_provider"
    t.text "preview_render_additive"
    t.index ["slug"], name: "index_teams_on_slug", unique: true
  end

  create_table "template_schemas", force: :cascade do |t|
    t.text "body"
    t.bigint "template_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "team_id"
    t.text "ui_schema"
    t.index ["team_id"], name: "index_template_schemas_on_team_id"
    t.index ["template_id"], name: "index_template_schemas_on_template_id"
  end

  create_table "template_tags", force: :cascade do |t|
    t.bigint "template_id", null: false
    t.bigint "tag_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["tag_id"], name: "index_template_tags_on_tag_id"
    t.index ["template_id"], name: "index_template_tags_on_template_id"
  end

  create_table "templates", force: :cascade do |t|
    t.text "body"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "team_id"
    t.string "description"
    t.text "preview_body"
    t.text "secondary_body", default: ""
    t.boolean "archived", default: false
    t.string "default_body"
    t.index ["team_id"], name: "index_templates_on_team_id"
  end

  create_table "translation_editor_colors", force: :cascade do |t|
    t.string "name"
    t.string "hex"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "team_id"
  end

  create_table "translation_projects", force: :cascade do |t|
    t.bigint "submission_id"
    t.string "title"
    t.datetime "due_date"
    t.bigint "team_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "provider"
  end

  create_table "translation_projects_pages", force: :cascade do |t|
    t.integer "translation_project_id"
    t.integer "page_id"
  end

  create_table "translations", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "crypted_password"
    t.string "salt"
    t.string "name"
    t.string "language"
    t.string "region"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "remember_me_token"
    t.datetime "remember_me_token_expires_at"
    t.string "reset_password_token"
    t.datetime "reset_password_token_expires_at"
    t.datetime "reset_password_email_sent_at"
    t.text "roles"
    t.text "allowed_countries"
    t.boolean "app_admin"
    t.bigint "team_id"
    t.string "auth_token"
    t.string "user_type"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["remember_me_token"], name: "index_users_on_remember_me_token"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token"
  end

  create_table "versions", force: :cascade do |t|
    t.string "item_type", null: false
    t.integer "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object"
    t.datetime "created_at"
    t.json "object_changes"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "asset_folders", "asset_folders"
  add_foreign_key "asset_folders", "teams"
  add_foreign_key "assets", "asset_folders"
  add_foreign_key "assets", "teams"
  add_foreign_key "country_groups", "teams"
  add_foreign_key "country_groups_locales", "country_groups"
  add_foreign_key "country_groups_locales", "locales"
  add_foreign_key "country_groups_pages", "country_groups"
  add_foreign_key "country_groups_pages", "pages"
  add_foreign_key "country_groups_schedules", "country_groups"
  add_foreign_key "country_groups_schedules", "schedules"
  add_foreign_key "country_groups_sites", "country_groups"
  add_foreign_key "country_groups_sites", "sites"
  add_foreign_key "customer_groups", "teams"
  add_foreign_key "customer_groups_schedules", "customer_groups"
  add_foreign_key "customer_groups_schedules", "schedules"
  add_foreign_key "locales", "sites"
  add_foreign_key "page_activities", "pages"
  add_foreign_key "page_activities", "teams"
  add_foreign_key "page_activities", "users"
  add_foreign_key "page_comments", "pages"
  add_foreign_key "page_comments", "users"
  add_foreign_key "page_contexts", "teams"
  add_foreign_key "page_folders", "page_folders"
  add_foreign_key "page_folders", "teams"
  add_foreign_key "page_modules", "teams"
  add_foreign_key "page_modules", "templates"
  add_foreign_key "page_modules_pages", "page_modules"
  add_foreign_key "page_modules_pages", "pages"
  add_foreign_key "page_modules_schedules", "page_modules"
  add_foreign_key "page_modules_schedules", "schedules"
  add_foreign_key "pages", "page_contexts"
  add_foreign_key "pages", "page_folders"
  add_foreign_key "pages", "teams"
  add_foreign_key "publishing_events", "publishing_manifests"
  add_foreign_key "publishing_locales", "pages"
  add_foreign_key "publishing_manifests", "pages"
  add_foreign_key "publishing_manifests", "publishing_targets"
  add_foreign_key "publishing_manifests", "users"
  add_foreign_key "publishing_manifests_sites", "publishing_manifests"
  add_foreign_key "publishing_manifests_sites", "sites"
  add_foreign_key "publishing_targets", "teams"
  add_foreign_key "roles", "teams"
  add_foreign_key "sales_force_configs", "teams"
  add_foreign_key "schedules", "pages"
  add_foreign_key "settings", "teams"
  add_foreign_key "sites", "teams"
  add_foreign_key "tags", "teams"
  add_foreign_key "template_schemas", "teams"
  add_foreign_key "template_schemas", "templates"
  add_foreign_key "template_tags", "tags"
  add_foreign_key "template_tags", "templates"
  add_foreign_key "templates", "teams"
end
