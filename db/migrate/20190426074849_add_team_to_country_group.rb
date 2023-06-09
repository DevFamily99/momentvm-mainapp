class AddTeamToCountryGroup < ActiveRecord::Migration[5.2]
  def change
    add_reference :country_groups, :team, foreign_key: true
  end
end
