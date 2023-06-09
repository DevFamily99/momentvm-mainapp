# frozen_string_literal: true

class AddPublishedToSchedules < ActiveRecord::Migration[5.2]
  def change
    add_column :schedules, :published, :boolean, default: false
  end
end
