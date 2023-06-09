class Mutations::UpdatePage < GraphQL::Schema::RelayClassicMutation
  argument :id, ID, required: true
  argument :name, String, required: false
  argument :context, String, required: false
  argument :publishing_folder, String, required: false
  argument :page_context_id, ID, required: false
  argument :category, String, required: false
  argument :country_groups, [String], required: false
  # argument :age, Integer, required: false

  field :page, Types::PageType, null: true
  field :errors, [String], null: false

  def resolve(params)
    page = Page.find(params[:id])
    country_groups = params[:country_groups]

    page.page_context_id = params[:page_context_id] if params[:page_context_id]
    page.name = params[:name] if params[:name]
    page.context = params[:context] if params[:context]
    page.publishing_folder = params[:publishing_folder] if params.key?(:publishing_folder)
    page.category = params[:category] if params[:category]

    unless page.country_groups.ids == country_groups
      if country_groups
        if country_groups.include?('none')
          page.country_groups = []
        else
          CountryGroupsPage.where(page_id: page.id).where.not(country_group_id: country_groups).destroy_all
          new_country_group = CountryGroup.find(country_groups)
          new_country_group.each { |cg| page.country_groups << cg unless page.country_groups.ids.include?(cg.id) }
        end
      end
    end
    if page.save
      {
        page: page
      }
    else
      raise page.errors.full_messages.join
    end
  end
end
