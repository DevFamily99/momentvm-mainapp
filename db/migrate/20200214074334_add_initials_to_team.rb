class AddInitialsToTeam < ActiveRecord::Migration[6.0]
  def change
    add_column :teams, :initials, :string
  end
end
