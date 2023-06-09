class AddHasThumbnailToPage < ActiveRecord::Migration[5.2]
  def change
    add_column :pages, :has_thumbnail, :Bool
  end
end
