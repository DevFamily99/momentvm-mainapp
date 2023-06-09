class CreateTranslationProjects < ActiveRecord::Migration[6.0]
  def change
    create_table :translation_projects do |t|
      t.bigint :submission_id
      t.string :title
      t.datetime :due_date
      t.bigint :team_id
      t.timestamps
    end
  end
end
