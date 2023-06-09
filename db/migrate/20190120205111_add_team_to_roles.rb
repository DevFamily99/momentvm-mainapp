class AddTeamToRoles < ActiveRecord::Migration[5.2]
  def change
    add_reference :roles, :team, foreign_key: true
  end
end
