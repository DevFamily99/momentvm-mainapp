class CreatePageModulesSchedules < ActiveRecord::Migration[5.2]
  def change
    create_table :page_modules_schedules do |t|
      t.references :page_module, foreign_key: true
      t.references :schedule, foreign_key: true

      t.timestamps
    end
  end
end
