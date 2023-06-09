module Mutations
    # Make a blueprint of a page and its page modules
    class BlueprintPage < GraphQL::Schema::RelayClassicMutation
      field :blueprint, Types::BlueprintType, null: false
  
      argument :page_id, ID, required: false
  
      def resolve(input)
        current_user = context[:current_user]
        page = Page.find(input[:page_id])
        
        blueprint = Blueprint.new
        blueprint.name = page.name + ' (blueprint)'
        page.page_modules.each do |page_module|
          blueprint.page_modules << update_page_module_body(page_module.dup)
        end
        if blueprint.save
          {
            blueprint: blueprint
          }
        else
          errors_json = {}
          blueprint.errors.each_key do |key|
            errors_json[key] = new_page.errors[key]
          end
          raise GraphQL::ExecutionError, errors_json.to_json
        end
      end

      def update_page_module_body(page_module)
        body = {}
        default_body = page_module_schema(page_module) || []

        default_body.keys.each do |attribute|
          body.merge!(Hash[attribute, default_body[attribute]['default'] || '' ])
        end
        page_module.body = body.as_json.to_yaml
        page_module.save!
        page_module
      end

      def page_module_schema(page_module)
        YAML.load(page_module.template.template_schema.body)
      end
    end
  end
  