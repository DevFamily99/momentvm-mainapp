class AddScreenshotStatusToPages < ActiveRecord::Migration[6.0]
  def change
    add_column :pages, :screenshot_status, :integer, default: 0
  end
end
