class CreateCustomerGroupsSchedules < ActiveRecord::Migration[6.0]
  def change
    create_table :customer_groups_schedules do |t|
      t.references :customer_group, foreign_key: true
      t.references :schedule, foreign_key: true

      t.timestamps
    end
  end
end
