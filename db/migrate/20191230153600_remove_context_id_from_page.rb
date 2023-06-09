class RemoveContextIdFromPage < ActiveRecord::Migration[5.2]
  def change
    remove_column :pages, :context_id
  end
end
