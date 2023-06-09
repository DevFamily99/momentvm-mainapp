# frozen_string_literal: true

require 'translation_service'
include PageFoldersHelper
include PagesHelper

module Types
  class QueryType < BaseObject
    # queries are just represented as fields
    # `all_links` is automatically camelcased to `allLinks`

    field :customer_groups, [CustomerGroupType], null: false
    def customer_groups
      current_user = context[:current_user]
      CustomerGroup.where(team: current_user.team)
    end

    field :customer_group, CustomerGroupType, null: false do
      argument :id, ID, required: true
      #   argument :name, String, required: false,
      #   argument :description String, required: false
    end
    def customer_group(id:)
      CustomerGroup.find(id)
    end

    field :country_groups, [CountryGroupType], null: false
    def country_groups
      current_user = context[:current_user]
      CountryGroup.where(team: current_user.team)
    end

    field :country_group, CountryGroupType, null: false do
      argument :id, ID, required: true
      #   argument :name, String, required: false,
      #   argument :description String, required: false
    end
    def country_group(id:)
      CountryGroup.find(id)
    end

    field :country_groups_connection, [CountryGroupType.connection_type], null: false
    # this method is invoked, when `all_link` fields is beeing resolved
    def country_groups_connection(**_args)
      CountryGroup.all
    end

    field :sites, [SiteType], null: false
    def sites(**_args)
      current_user = context[:current_user]
      Site.where(team_id: current_user.team_id)
    end

    field :unique_locales, [LocaleType], null: false
    def unique_locales
      context[:current_user].team.sites.map(&:locales).flatten.uniq(&:code)
    end

    field :pages, [PageType], null: false do
      argument :search_term, String, required: false
      argument :max_results, Int, required: false
      argument :order, String, required: false
    end
    def pages(**_args)
      search_term = _args[:search_term]
      max_results = _args[:max_results]
      order = _args[:order]
      current_user = context[:current_user]
      query = ''
      query = ActiveRecord::Base.sanitize_sql_like(search_term) if search_term

      Page.where('name ILIKE ?', '%' + query + '%').or(Page.where('id::TEXT LIKE ?', '%' + query + '%')).where(
        team_id: current_user.team_id
      )
          .order("#{order || 'created_at'} DESC")
          .limit(max_results || 30)
    end

    field :page_views, [PageViewType], null: true
    def page_views
      current_user = context[:current_user]
      current_user.page_views.joins(:page).where("team_id = #{current_user.team_id}").last(10)
    end

    field :page_activities, [PageActivityType], null: false
    def page_activities
      current_user = context[:current_user]
      PageActivity.includes(:page).where(team_id: current_user.team_id).distinct(:page_id).last(20)
    end

    field :page, PageType, null: true do
      argument :id, ID, required: true
    end
    def page(id:)
      current_user = context[:current_user]
      page = current_user.team.pages.find(id)
      # page = Page.includes(:page_modules, :country_groups, schedules: [{ country_groups: { sites: :locales } }, :customer_groups]).find(id)
      # add a page view
      add_page_view_for(page, current_user)
      page
    end

    field :templates, [TemplateType], null: true do
      argument :archived, Boolean, required: false
      argument :ids, [ID], required: false
    end
    def templates(**args)
      current_user = context[:current_user]
      return Template.includes(image_attachment: :blob).where(team_id: current_user.team_id).where(id: args[:ids]) if args[:ids]

      templates = Template.includes(image_attachment: :blob).where(team_id: current_user.team_id)
      if args[:archived]
        templates.archived
      else
        templates.unarchived
      end
    end

    field :template_search, [TemplateType], null: true do
      argument :query, String, required: false
    end
    def template_search(query:)
      current_user = context[:current_user]
      templates = Template.includes(image_attachment: :blob).where(team_id: current_user.team_id)
      templates = templates.search(query) unless query.empty?
      templates
    end

    field :version, VersionType, null: true do
      argument :id, ID, required: true
    end
    def version(id:)
      PaperTrail::Version.find(id)
    end

    field :template, TemplateType, null: true do
      argument :id, ID, required: true
    end
    def template(id:)
      Template.find(id)
    end

    field :page_contexts, [PageContextType], null: false
    def page_contexts
      current_user = context[:current_user]
      PageContext.where(team: current_user.team)
    end

    field :page_context, PageContextType, null: false do
      argument :id, ID, required: true
      #   argument :name, String, required: false,
      #   argument :description String, required: false
    end
    def page_context(id:)
      PageContext.find(id)
    end

    field :tags, [TagType], null: false
    def tags
      Tag.where(team: context[:current_user].team)
    end

    field :schedules, [ScheduleType], null: true do
      argument :page, ID, required: false
    end
    def schedules(**_args)
      _args[:page] ? Page.find(_args[:page]).schedules.order(:created_at) : Schedule.all.order(created_at: :desc)
    end

    field :page_folders, [PageFolderType], null: true do
      argument :page, ID, required: true
    end
    def page_folders(**_args)
      pageFolder = Page.find(_args[:page]).page_folder
      breadcrumb(pageFolder)
    end

    field :schedule, ScheduleType, null: false do
      argument :id, ID, required: true
    end
    def schedule(id:)
      Schedule.find(id)
    end

    field :translation, TranslationType, null: false do
      argument :id, ID, required: true
    end
    def translation(id:)
      # Translation is a virtual type. It does not exist in this app
      # Therefore we trigger a sub query to translation service to retreive the data
      ts = TranslationService.new
      response = ts.get_translation(id)
      parsed = JSON.parse(response.body)
      raise GraphQL::ExecutionError, "#{id} not found" if parsed["errors"]
      return parsed["data"]["translation"]
    end

    # returns - NOTSENT, PENDING, READY, ERROR
    field :translation_project_status, String, null: false do
      argument :page_id, String, required: true
    end
    def translation_project_status(page_id:)
      page = Page.find(page_id)
      return 'NOTSENT' if page.translation_project_id.nil?

      ts = TranslationService.new
      ts.check_translaiton_status(page_id) do |error|
        status = 'ERROR' if error
        status = JSON.parse(ts.body)['status']
      end
    end

    field :translations, [TranslationType], null: false do
      argument :ids, [ID], required: true
    end
    def translations(ids:)
      req = Request.new
      req.send_request(
        url: Rails.configuration.translation_service[:url] + '/api/translations/list',
        body: { translations: ids },
        options: {
          type: :post,
          username: Rails.configuration.translation_service[:username],
          password: Rails.configuration.translation_service[:password]
        }
      ) do |response_code, response|
        raise 'Translaiton fetch error' if response_code != 200

        return JSON.parse(response.body)['translations']
      end
    end

    field :search_translations, [TranslationType], null: false do
      argument :query, String, required: true
    end
    def search_translations(query:)
      current_user = context[:current_user]
      t = TranslationService.new
      t.search_for_translation(query: query, team_id: current_user.team_id) do |err|
        raise 'Error Searching Translations' if err
      end
      JSON.parse(t.body)
    end

    field :reused_translation, [PageModuleType], null: false do
      argument :translation_id, String, required: true
    end
    def reused_translation(translation_id:)
      current_user = context[:current_user]
      PageModule.where(team_id: current_user.team_id).where('body LIKE ?', '%loc::' + translation_id + '%')
    end

    field :translation_projects, [TranslationProjectType], null: true
    def translation_projects
      current_user = context[:current_user]
      TranslationProject.where(team_id: current_user.team_id).order(created_at: :desc)
    end

    field :translation_project, GraphQL::Types::JSON, null: false do
      argument :submission_id, ID, required: true
      argument :provider, TranslationProvider, required: true
    end
    def translation_project(submission_id:, provider:)
      current_user = context[:current_user]
      project = TranslationProject.where(team_id: current_user.team_id).find_by(submission_id: submission_id)
      raise GraphQL::ExecutionError, 'Submission not found' unless project

      t = TranslationService.new
      if provider == 'LW'
        t.get_project(submission_id)
        JSON.parse(t.body)
      elsif provider == 'GLOBALLINK'
        t.fetch_submission(submission_id) { |response| return JSON.parse response.body }
      end
    end

    field :asset_folder, AssetFolderType, null: false do
      argument :path, String, required: true
    end
    def asset_folder(path:)
      current_user = context[:current_user]
      return AssetFolder.by_team(current_user).where(asset_folder_id: nil).first if path.delete_suffix('/') == '/assets'
      return AssetFolder.by_team(current_user).where(asset_folder_id: nil, name: 'Archive').first if path == '/asset_archive'

      AssetFolder.by_team(current_user).find_by(slug: path.split('/').last)
    end

    field :page_folder, PageFolderType, null: false do
      argument :path, String, required: true
    end
    def page_folder(path:)
      current_user = context[:current_user]
      return PageFolder.by_team(current_user).where(page_folder_id: nil).first if path.delete_suffix('/') == '/page_folders'
      return PageFolder.by_team(current_user).where(name: 'Archive').first if path.delete_suffix('/') == '/page_archive'

      PageFolder.by_team(current_user).find_by(slug: path.split('/').last)
    end

    field :publishing_targets, [PublishingTargetType], null: false
    def publishing_targets(**_args)
      current_user = context[:current_user]
      PublishingTarget.where(team_id: current_user.team.id)
    end

    field :publishing_manifests, [PublishingManifestType], null: false do
      argument :schedule_id, ID, required: false
      argument :page_id, ID, required: false
    end
    def publishing_manifests(schedule_id:, page_id:)
      raise 'Need to provide either schedule_id or page_id' if schedule_id.nil? && page_id.nil?

      return PublishingManifest.where(schedule_id: schedule_id).order(created_at: :desc).first(20) if schedule_id
      return PublishingManifest.where(page_id: page_id).order(created_at: :desc).first(20) if page_id
    end

    field :blueprints, [BlueprintType], null: false
    def blueprints
      Blueprint.all.order(created_at: :asc)
    end

    field :teams, [TeamType], null: false
    def teams
      Team.all.order(created_at: :asc)
    end

    field :team,
          TeamType,
          null: false,
          description: 'Gets the team by the provided slug, if no id is passed returns the current users team' do
      argument :slug, String, required: false
    end
    def team(input = {})
      return Team.find_by(slug: input[:slug]) if input[:slug]

      current_user = context[:current_user]
      current_user.team
    end

    field :plans, [PlanType], null: false
    def plans
      Plan.all
    end

    field :current_team, TeamType, null: false
    def current_team(**_args)
      current_user = context[:current_user]
      Team.where(id: current_user.team.id).first
    end

    field :page_module, PageModuleType, null: false do
      argument :page_module_id, ID, required: true
    end
    def page_module(page_module_id:)
      page_module = PageModule.find(page_module_id)
      current_user = context[:current_user]
      raise 'Unauthorized' if current_user.team != page_module.team

      page_module
    end

    field :images, Connections::AssetConnection, null: false do
      argument :search_term, String, required: false
    end
    def images(search_term:)
      current_user = context[:current_user]
      query = Asset.sanitize_sql_like(search_term)
      Asset.select(:id, :name).includes(image_attachment: :blob)
           .where(team_id: current_user.team_id)
           .where('name ILIKE ?', '%' + query + '%')
           .order(updated_at: :desc)
    end

    field :asset, AssetType, null: false do
      argument :id, ID, required: true
    end
    def asset(id:)
      Asset.find(id)
    end

    field :setting, SettingType, null: false do
      argument :name, String, required: true
    end
    def setting(name:)
      current_user = context[:current_user]
      Setting.where(team_id: current_user.team_id).find_by(name: name)
    end

    field :pageTranslations, GraphQL::Types::JSON, null: false do
      argument :page_id, ID, required: false
    end
    def page_translations(page_id:)
      puts 'page_translations'
      Page.find(page_id).get_translations(context[:current_user])
    end

    field :locales, [String], null: false
    def locales
      current_user = context[:current_user]
      setting = Setting.where(team_id: current_user.team_id).find_by(name: 'editor-locales')
      return YAML.load(setting.body) if setting

      current_user.team.all_locales
    end

    field :target_languages, [String], null: false
    def target_languages
      current_user = context[:current_user]
      setting = Setting.where(team_id: current_user.team_id).find_by(name: 'target-languages')
      return YAML.load(setting.body) if setting

      current_user.team.all_locales
    end

    field :translation_editor_colors, [TranslationEditorColorType], null: true
    def translation_editor_colors
      TranslationEditorColor.where(team_id: context[:current_user].team_id)
    end

    field :roles, [RoleType], null: false
    def roles
      current_user = context[:current_user]
      Role.where(team_id: current_user.team_id)
    end

    # used for module permisssions in the editor
    field :role_whitelist, [RoleWhitelistType], null: true do
      argument :page_module_id, ID, required: true
    end
    def role_whitelist(page_module_id:)
      PageModule.find(page_module_id).page_module_role_whitelists
    end

    field :global_search, GlobalSearchResultType, null: true do
      argument :term, String, required: true
    end
    def global_search(term:)     
      term = term.gsub('+',' ');
      current_user = context[:current_user]
      results = PgSearch.multisearch(term).where(team_id: current_user.team_id).group_by(&:searchable_type)
      assets = nil
      assets = Asset.where(id: results['Asset'].map(&:searchable_id)) if results['Asset']
      pages = nil
      pages = Page.find(results['Page'].map(&:searchable_id)) if results['Page']
      if results['Template']
        template = Template.find(results['Template'].map(&:searchable_id)).select {|t| t.name == term}
        ids = Template.includes(page_modules: [:pages]).where(id: template.first.id).pluck("pages.id")
        pages = Page.find ids
      end
      {
        pages: pages,
        assets: assets
      }
    end

    field :user, UserType, null: false do
      argument :id, ID, required: true
    end
    def user(id:)
      # check permissions first
      User.find(id)
    end

    field :all_skills, GraphQL::Types::JSON, null: false do
      description 'all the skills from the role model'
    end
    def all_skills
      Role.all_skills
    end
  end
end
