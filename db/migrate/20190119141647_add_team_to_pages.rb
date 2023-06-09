class AddTeamToPages < ActiveRecord::Migration[5.2]
  def change
    add_reference :pages, :team, foreign_key: true
  end
end
