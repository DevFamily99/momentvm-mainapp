class CreateTranslationProjectsPages < ActiveRecord::Migration[6.0]
  def change
    create_table :translation_projects_pages do |t|
      t.integer :translation_project_id
      t.integer :page_id
    end
  end
end
