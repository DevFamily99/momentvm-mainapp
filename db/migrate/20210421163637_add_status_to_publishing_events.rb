class AddStatusToPublishingEvents < ActiveRecord::Migration[6.0] # :nodoc:
  def change
    add_column :publishing_events, :status, :string
  end
end
