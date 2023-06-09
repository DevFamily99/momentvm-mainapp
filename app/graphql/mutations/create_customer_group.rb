# frozen_string_literal: true

module Mutations
  class CreateCustomerGroup < GraphQL::Schema::RelayClassicMutation
     field :customer_group, Types::CustomerGroupType, null: false

     argument :name, String, required: true

     def resolve(name:)
       puts 'create customer gruop!'
       current_user = context[:current_user]
       customer_group = CustomerGroup.new(name: name, team: current_user.team)
     
       if customer_group.save
         {
           customer_group: customer_group
         }
       else
        p customer_group.errors[:name]
        errors_json = {}
        customer_group.errors.keys.each do |key|
          errors_json[key] = customer_group.errors[key]
        end
        raise GraphQL::ExecutionError, errors_json.to_json
       end
      end
  end
end
