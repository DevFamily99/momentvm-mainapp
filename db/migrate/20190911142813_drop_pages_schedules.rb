# frozen_string_literal: true

class DropPagesSchedules < ActiveRecord::Migration[5.2]
  def change
    drop_table :pages_schedules
  end
end
