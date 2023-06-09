module Mutations
  class CreatePage < GraphQL::Schema::RelayClassicMutation
    field :page, Types::PageType, null: false

    argument :page_folder_id, ID, required: false
    argument :classic, Boolean, required: false

    def resolve(input)
      current_user = context[:current_user]
      if input[:page_folder_id]
        page_folder = PageFolder.find(input[:page_folder_id])
      else
        page_folder =  PageFolder.by_team(current_user).where(page_folder_id: nil).first 
      end
      page = Page.new(
        name: 'New Page',
        page_folder_id: page_folder.id,
        team: current_user.team,
        context_type: input[:classic] ? nil : 'supports_schedules'
      )
      if page.save
        {
          page: page
        }
      else
        errors_json = {}
        page.errors.keys.each do |key|
          errors_json[key] = page.errors[key]
        end
        raise GraphQL::ExecutionError, errors_json.to_json
      end
     end
  end
end
