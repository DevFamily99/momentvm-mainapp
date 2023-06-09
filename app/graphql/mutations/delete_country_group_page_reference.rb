# To remove the join table object which links a schedule
# and a CountryGroup
module Mutations
  class DeleteCountryGroupPageReference < GraphQL::Schema::RelayClassicMutation
    #field :schedule_country_group, Types::ScheduleCountryGroupType, null:false
    argument :page_id, ID, required: true
    argument :country_group_id, ID, required: true
    
    field :page, Types::PageType, null: false
    field :country_group, Types::CountryGroupType, null: false
    
    def resolve(page_id:, country_group_id:)
      page = Page.find(page_id)
      country_group = CountryGroup.find(country_group_id)
      join_table_instance = page.country_groups.find(country_group_id)
      page.country_groups.delete(join_table_instance)
      {
        page: page,
        country_group: country_group
      }
     end

  end
end
