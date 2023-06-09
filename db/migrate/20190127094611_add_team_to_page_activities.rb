class AddTeamToPageActivities < ActiveRecord::Migration[5.2]
  def change
    add_reference :page_activities, :team, foreign_key: true
  end
end
