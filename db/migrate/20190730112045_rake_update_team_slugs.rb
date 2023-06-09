class RakeUpdateTeamSlugs < ActiveRecord::Migration[5.2]
  def change
    Team.find_each(&:save)
  end
end
