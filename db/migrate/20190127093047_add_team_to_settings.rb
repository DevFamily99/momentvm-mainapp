class AddTeamToSettings < ActiveRecord::Migration[5.2]
  def change
    add_reference :settings, :team, foreign_key: true
  end
end
