# frozen_string_literal: true

class AddScreenshotStatusToSchedules < ActiveRecord::Migration[5.2]
  def change
    add_column :schedules, :screenshot_status, :integer, default: 0
  end
end
