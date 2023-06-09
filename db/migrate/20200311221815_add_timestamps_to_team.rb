class AddTimestampsToTeam < ActiveRecord::Migration[6.0]
  def change
    add_timestamps :teams, default: Time.zone.now
  end
end
