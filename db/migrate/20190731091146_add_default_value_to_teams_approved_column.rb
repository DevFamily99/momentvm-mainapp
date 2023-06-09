class AddDefaultValueToTeamsApprovedColumn < ActiveRecord::Migration[5.2]
  def change
    change_column_default :teams, :approved, false
  end
end
