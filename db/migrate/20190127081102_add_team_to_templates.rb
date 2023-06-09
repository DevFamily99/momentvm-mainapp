class AddTeamToTemplates < ActiveRecord::Migration[5.2]
  def change
    add_reference :templates, :team, foreign_key: true
  end
end
