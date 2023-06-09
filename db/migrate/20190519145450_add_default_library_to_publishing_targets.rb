class AddDefaultLibraryToPublishingTargets < ActiveRecord::Migration[5.2]
  def change
    add_column :publishing_targets, :default_library, :string
  end
end
