# frozen_string_literal: true

class AddTeamToPgSearchDocuments < ActiveRecord::Migration[5.2]
  def change
    add_column :pg_search_documents, :team_id, :integer
  end
end
