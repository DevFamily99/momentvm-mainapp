# frozen_string_literal: true

module Types
  class PageType < BaseObject
    field :id, ID, null: false
    field :name, String, null: false
    field :category, String, null: true
    field :title, String, null: true
    field :description, String, null: true
    field :keywords, String, null: true
    field :url, String, null: true
    field :is_searchable, Boolean, null: true
    field :page_modules, [PageModuleType], null: true
    field :schedules, [ScheduleType], null: true
    field :country_groups, [CountryGroupType], null: true
    field :page_context, PageContextType, null: true
    field :all_locales, [String], null: true
    field :publishing_locales, [PublishingLocaleType], null: true
    field :publish_assets, Boolean, null: true
    field :publishing_manifests, [PublishingManifestType], null: true
    field :thumb, String, null: true
    field :thumbnail, String, null: true
    field :safe_name, String, null: false
    field :allowed_countries, GraphQL::Types::JSON, null: true, description: 'The countries the current user can edit'
    field :context, String, null: true, resolver_method: :resolve_context
    field :publishing_folder, String, null: true
    field :page_activities, [PageActivityType], null: true
    field :page_folder, PageFolderType, null: false
    field :created_at, String, null: false 
    field :updated_at, String, null: false
    field :last_published, String, null: true
    field :duplicated_from_page_link, String, null: true
    field :duplicated_from_page, String, null: true
    field :last_sent_to_translation, String, null:true
    field :last_imported_translation, String, null: true
    field :deleted_from_archive, String, null: true
    field :created_by, String, null:true
    field :updated_by, String, null:true
    field :sent_to_translation_by, String
    field :translation_imported_by, String
    field :published_by, String
    field :deleted_from_archive_by, String

    def created_by
      object.created_by
    end

    def updated_by
      object.updated_by
    end

    def sent_to_translation_by
      object.send_to_translation_by
    end

    def translation_imported_by
      object.translation_imported_by
    end
    
    def published_by
      object.published_by
    end

    def deleted_from_archive_by
      object.deleted_from_archive_by
    end
    
    def resolve_context
      object.context
    end

    # Only needed for legacy reasons
    def allowed_countries
      # taken from pages_controller#show
      current_user = context[:current_user]
      @publishingLocales = object.publishing_locales.sort_by(&:locale)
      @publishingSites = []
      @publishingLocales.each do |pubLocale|
        # pubLocale is a country ID
        localesForSite =
          SettingService.get_locales_for_site(pubLocale.locale, current_user)
        @publishingSites << { id: pubLocale.locale, name: pubLocale.name, locales: localesForSite }
      end
      @publishingSites
    end

    def all_locales
      sites = Site.includes(:locales).where(team_id: object.team_id)
      locales = sites.map(&:locales).flatten
      locales.map(&:code).uniq
    end

    def page_modules
      object.page_modules.order(rank: :asc)
    end

    def category
      return object.category if object.category

      'unset'
    end

    def thumbnail
      object.thumb
    end

    def publishing_locales
      object.publishing_locales.order(locale: :asc)
    end

    def publishing_manifests
      object.publishing_manifests.includes(:publishing_target, :user, :publishing_events).order(created_at: :desc)
    end

    # end page
  end
end
