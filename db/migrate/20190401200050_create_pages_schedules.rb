class CreatePagesSchedules < ActiveRecord::Migration[5.2]
  def change
    create_table :pages_schedules do |t|
      t.references :page, foreign_key: true
      t.references :schedule, foreign_key: true

      t.timestamps
    end
  end
end
