module Mutations
  class DeleteCountryGroup < GraphQL::Schema::RelayClassicMutation
    argument :id, ID, required: true

    field :countryGroup, Types::CountryGroupType, null: true
  
    def resolve(id:)
      countryGroup = CountryGroup.find(id)
 
      countryGroup.destroy!
      { countryGroup: countryGroup }
     end

  end
end
