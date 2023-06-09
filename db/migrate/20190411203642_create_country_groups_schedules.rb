class CreateCountryGroupsSchedules < ActiveRecord::Migration[5.2]
  def change
    create_table :country_groups_schedules do |t|
      t.references :country_group, foreign_key: true
      t.references :schedule, foreign_key: true

      t.timestamps
    end
  end
end
