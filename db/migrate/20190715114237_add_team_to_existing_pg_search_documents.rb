# frozen_string_literal: true

class AddTeamToExistingPgSearchDocuments < ActiveRecord::Migration[5.2]
  def change
    # check if there are assets without a team id
    non_assigned_assets = Asset.where(team_id: nil)
    stokke_team = Team.find_by_name('STOKKE')
    non_assigned_assets.each do |a|
      a.team_id = stokke_team.id
      a.save
    end
    # rebuild the documents and add the team id
    PgSearch::Multisearch.rebuild(Page)
    PgSearch::Multisearch.rebuild(Asset)
    pages = Page.all
    assets = Asset.all
    pages.each(&:update_pg_search_document)
    assets.each(&:update_pg_search_document)
  end
end
