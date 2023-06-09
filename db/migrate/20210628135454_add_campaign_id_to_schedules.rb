class AddCampaignIdToSchedules < ActiveRecord::Migration[6.0] #:nodoc:
  def change
    add_column :schedules, :campaign_id, :string
  end
end
