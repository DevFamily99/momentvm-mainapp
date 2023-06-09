class Mutations::UpdatePageContext < GraphQL::Schema::RelayClassicMutation
  argument :id, ID, required: true
  argument :name, String, required: true
  argument :context_type, String, required: true
  argument :slot, String, required: true
  argument :selector, String, required: false
  argument :rendering_template, String, required: false
  argument :preview_wrapper_url, String, required: false

  field :page_context, Types::PageContextType, null: true
  field :errors, [String], null: false

  def resolve(params)
    page_context = PageContext.find(params[:id])
    page_context.name = params[:name] 
    page_context.context = params[:context_type]
    page_context.slot = params[:slot] 
    page_context.selector = params[:selector] if params[:selector]
    page_context.rendering_template = params[:rendering_template] if params[:rendering_template]
    page_context.preview_wrapper_url = params[:preview_wrapper_url] if params[:preview_wrapper_url]
    if page_context.save
      {
        page_context: page_context
      }
    else
      raise page_context.errors.full_messages.join
    end
  end
end
