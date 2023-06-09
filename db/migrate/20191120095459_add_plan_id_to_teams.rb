class AddPlanIdToTeams < ActiveRecord::Migration[5.2]
  def change
    add_column :teams, :plan_id, :integer, references: 'plans'
  end
end
