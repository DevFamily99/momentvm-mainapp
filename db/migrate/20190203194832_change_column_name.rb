class ChangeColumnName < ActiveRecord::Migration[5.2]
  def change
    rename_column :teams, :company, :name
  end
end
