# To remove the join table object which links a schedule
# and a CountryGroup
module Mutations
    class DeleteBlueprint < GraphQL::Schema::RelayClassicMutation
      #field :schedule_country_group, Types::ScheduleCountryGroupType, null:false
      argument :id, ID, required: true
      
      field :blueprint, Types::BlueprintType, null: false
      
      def resolve(id:)
        blueprint = Blueprint.find(id)
            
        blueprint.destroy!
        {blueprint: blueprint}
       end
  
    end
  end
  