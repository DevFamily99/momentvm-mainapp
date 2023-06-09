# frozen_string_literal: true

module Types
    class BlueprintType < BaseObject
      field :id, ID, null: false
      field :name, String, null: false
      field :page_modules, [PageModuleType], null: true
     
      def page_modules
        object.page_modules.order(rank: :asc)
      end
  
    end
  end
  