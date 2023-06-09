module Mutations
  # Make a copy of a page and its page modules
  class DuplicatePage < GraphQL::Schema::RelayClassicMutation
    field :page, Types::PageType, null: false

    argument :page_id, ID, required: false

    def resolve(input)
      current_user = context[:current_user]
      raise 'Permission denied' unless current_user.has_skill?('can_duplicate_page')
      page = Page.find(input[:page_id])
      new_page = page.dup
      new_page.name = page.name + ' (copy)'
      new_page.duplicated_from_page = DateTime.now
      new_page.duplicated_from_page_link = "'/pages/" + page.id.to_s + "'"
      page.page_modules.each do |page_module|
        new_page_module = page_module.dup
        new_page.page_modules << new_page_module
        new_page_module.save
      end

      if new_page.save
        {
          page: new_page
        }
      else
        errors_json = {}
        new_page.errors.each_key do |key|
          errors_json[key] = new_page.errors[key]
        end
        raise GraphQL::ExecutionError, errors_json.to_json
      end
    end
  end
end
