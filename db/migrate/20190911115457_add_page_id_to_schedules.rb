class AddPageIdToSchedules < ActiveRecord::Migration[5.2]
  def change
    add_reference :schedules, :page, foreign_key: true
  end
end
