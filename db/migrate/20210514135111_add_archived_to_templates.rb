class AddArchivedToTemplates < ActiveRecord::Migration[6.0] #:nodoc:
  def change
    add_column :templates, :archived, :boolean, default: false
  end
end
