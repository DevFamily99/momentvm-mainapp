module Mutations
  class DeleteCustomerGroup < GraphQL::Schema::RelayClassicMutation
    argument :id, ID, required: true

    field :customer_group, Types::CustomerGroupType, null: true
  
    def resolve(id:)
      customer_group = CustomerGroup.find(id)
      customer_group.destroy!
      { customer_group: customer_group }
     end

  end
end
