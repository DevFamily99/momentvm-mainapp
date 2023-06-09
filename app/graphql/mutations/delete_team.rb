# To remove the join table object which links a schedule
# and a CountryGroup
module Mutations
  class DeleteTeam < GraphQL::Schema::RelayClassicMutation
    #field :schedule_country_group, Types::ScheduleCountryGroupType, null:false
    argument :id, ID, required: true
    
    field :team, Types::TeamType, null: false
    
    def resolve(id:)
      team = Team.find(id)
      pageFolders = PageFolder.where(team: id)
      pageFolders.destroy_all
      assetFolders = AssetFolder.where(team_id: id)
      assetFolders.destroy_all
          
      team.destroy!
      {team: team}
     end

  end
end
