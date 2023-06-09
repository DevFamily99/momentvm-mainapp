class AddShowSetupAssistantToTeam < ActiveRecord::Migration[5.2]
  def change
    add_column :teams, :show_setup_assistant, :boolean, default: false
  end
end
