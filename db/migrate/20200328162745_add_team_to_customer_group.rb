class AddTeamToCustomerGroup < ActiveRecord::Migration[6.0]
  def change
    add_reference :customer_groups, :team, foreign_key: true
 
  end
end
