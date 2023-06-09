class AddContextIdToPage < ActiveRecord::Migration[5.2]
  def change
    add_column :pages, :context_id, :integer, index: true
  end
end
