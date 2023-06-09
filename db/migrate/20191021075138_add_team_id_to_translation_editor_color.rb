# frozen_string_literal: true

class AddTeamIdToTranslationEditorColor < ActiveRecord::Migration[5.2]
  def change
    add_column :translation_editor_colors, :team_id, :integer, references: 'teams'
  end
end
