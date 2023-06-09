class AddProxyTargetToTeam < ActiveRecord::Migration[5.2]
  def change
    add_column :teams, :preview_wrapper_url, :string
    add_column :teams, :selector, :string
  end
end
