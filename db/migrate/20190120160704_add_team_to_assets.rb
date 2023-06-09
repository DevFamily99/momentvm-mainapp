class AddTeamToAssets < ActiveRecord::Migration[5.2]
  def change
    add_reference :assets, :team, foreign_key: true
  end
end
