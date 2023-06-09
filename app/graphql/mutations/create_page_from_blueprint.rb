module Mutations
    class CreatePageFromBlueprint < GraphQL::Schema::RelayClassicMutation
      field :page, Types::PageType, null: false
  
      argument :page_folder_id, ID, required: false
      argument :classic, Boolean, required: false
      argument :blueprint_id, ID, required: false
      
  
      def resolve(input) 
        current_user = context[:current_user]
        if input[:page_folder_id]
          page_folder = PageFolder.find(input[:page_folder_id])
        else
          page_folder =  PageFolder.by_team(current_user).where(page_folder_id: nil).first 
        end
        blueprint = Blueprint.find(input[:blueprint_id])
        page = Page.new(
          name: 'New Page created from Blueprint-' + blueprint.name,
          page_folder_id: page_folder.id,
          team: current_user.team,
          context_type: input[:classic] ? nil : 'supports_schedules'
        )        
        blueprint.page_modules.each do |blueprint_page_module|
          page_module = PageModule.new
          page_module.team = current_user.team
          page_module.rank = blueprint_page_module.rank
          page_module.template_id = blueprint_page_module.template_id
          page_module.body = blueprint_page_module.body
          page_module.save
          page.page_modules << page_module
        end
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
  