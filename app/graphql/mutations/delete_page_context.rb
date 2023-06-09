module Mutations
  class DeletePageContext < GraphQL::Schema::RelayClassicMutation
    argument :id, ID, required: true

    field :pageContext, Types::PageContextType, null: true
  
    def resolve(id:)
      pageContext = PageContext.find(id)
      pageContext.destroy!
      { pageContext: pageContext }
     end

  end
end
