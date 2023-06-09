include PageModulesHelper
module Mutations
  class CopyPageModule < GraphQL::Schema::RelayClassicMutation
    field :page_module, Types::PageModuleType, null: false
    argument :page_id, ID, required: true
    argument :page_module_id, ID, required: true
    argument :create_below, ID, required: false

    def resolve(input)
      current_user = context[:current_user]
      page = Page.find(input[:page_id])
      module_to_copy = PageModule.find(input[:page_module_id])
      page_module = PageModule.new(
      body: module_to_copy.body,
      template_id: module_to_copy.template_id,
      schedule: module_to_copy.schedule
      )
      page_module.team = current_user.team
      page_module.pages << page

      if input[:create_below].nil?
        page_module.rank = 'z'
        page_module.save!
        return {page_module: page_module}
      else
        # if a module id is sent to create bellow
        # first save the page module and then update the ranks of all of the modules on the page
        current_order = page.page_modules.order(:rank).pluck(:id)
        page_module.save!
        index_of_module_before_inserted = current_order.find_index(input[:create_below].to_i)
        current_order.insert(index_of_module_before_inserted + 1, page_module.id)
        update_page_module_ranks(current_order)
        return {page_module: page_module}
      end
    end
  end
end
