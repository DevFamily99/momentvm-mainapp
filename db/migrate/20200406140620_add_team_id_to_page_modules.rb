class AddTeamIdToPageModules < ActiveRecord::Migration[6.0]
  def change
    add_reference :page_modules, :team, foreign_key: true
  end
end
