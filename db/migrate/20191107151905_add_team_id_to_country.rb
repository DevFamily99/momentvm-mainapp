class AddTeamIdToCountry < ActiveRecord::Migration[5.2]
  def change
    add_column :countries, :team_id, :integer, references: 'teams'
  end
end
