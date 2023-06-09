class AddObjectChangesColumnToVersions < ActiveRecord::Migration[6.1]
  def change
    change_table :versions do |t|
      t.json :object_changes  
    end
  end
end
