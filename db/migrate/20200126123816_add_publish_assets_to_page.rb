class AddPublishAssetsToPage < ActiveRecord::Migration[5.2]
  def change
    add_column :pages, :publish_assets, :bool
  end
end
