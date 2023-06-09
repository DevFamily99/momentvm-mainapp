# frozen_string_literal: true

module Mutations
  class UpdateCustomerGroup < GraphQL::Schema::RelayClassicMutation
    field :customer_group, Types::CustomerGroupType, null: true

    argument :id, ID, required: true
    argument :name, String, required: true

    def resolve(id:, name:)
      customer_group = CustomerGroup.find(id)
      customer_group.name = name
      if customer_group.save!
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
