class AddTeamToTemplateSchemas < ActiveRecord::Migration[5.2]
  def change
    add_reference :template_schemas, :team, foreign_key: true
  end
end
