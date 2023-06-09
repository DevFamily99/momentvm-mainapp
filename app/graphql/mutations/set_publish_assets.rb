module Mutations
  class SetPublishAssets < GraphQL::Schema::RelayClassicMutation
    argument :page_id, ID, required: true
    argument :publish_assets, Boolean, required: true

    field :page, Types::PageType, null: true

    def resolve(input)
      puts input
      page = Page.find(input[:page_id])
      page.publish_assets = input[:publish_assets]
      puts page.inspect
      if page.save!
        return {page: page}
      else
        raise "Setting publish assets failed."
      end
    end

  end
end
