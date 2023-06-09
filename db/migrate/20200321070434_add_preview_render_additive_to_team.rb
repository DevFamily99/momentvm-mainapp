class AddPreviewRenderAdditiveToTeam < ActiveRecord::Migration[6.0]
  def change
    add_column :teams, :preview_render_additive, :text
  end
end
