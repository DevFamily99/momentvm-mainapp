# frozen_string_literal: true

Rails.application.routes.draw do

  mount ActionCable.server, at: '/cable'
  namespace :admin do
    resources :plans
    resources :teams do
      member { get :set_team }
    end
  end

  get '/team-settings', to: 'teams#settings', as: 'team_settings'
  get '/retrieve_current_team', to: 'teams#retrieve_current_team'
  get '/check-team-setup', to: 'teams#check_team_setup'
  get '/salesforce_sites', to: 'teams#salesforce_sites'
  get '/team_sites', to: 'teams#team_sites'
  post '/import_sites', to: 'teams#import_sites'
  post '/clear_sites', to: 'teams#clear_sites'

  resources :customer_groups
  mount GraphiQL::Rails::Engine, at: '/graphiql', graphql_path: '/graphql' if Rails.env.development?
  post '/graphql', to: 'api/graphql#execute'

  get 'pages/:id/export_xml', to: 'pages#export_xml', as: :export_xml

  get 'roles/:id/remove_user_from_role/:user_id', to: 'roles#remove_user_from_role', as: 'remove_user_from_role'

  get 'home/index'
  get '/captcha_site_key', to: 'home#captcha_site_key'

  resources :page_activities
  get 'job_monitor/index'

  get 'workflow/validate_pages_start'
  post 'workflow/validate_pages'
  get 'workflow/send_translations_start'
  post 'workflow/send_translations'
  get 'workflow/check_finished_translations_start'
  get 'workflow/translation_projects'

  resources :settings

  resources :media_files, controller: 'assets' do
    get 'new_asset_in_folder', on: :member
    post 'list', action: :list, on: :collection
    post 'list_named', action: :list_named, on: :collection
  end

  resources :pages do
    get 'new_page_in_folder', on: :member
    get 'new_classic_page_in_folder', on: :member
    post 'attach_thumbnail', on: :member
    get 'show_json', on: :member
    get 'upload_thumbnail', on: :member
    get 'without_thumbnail', on: :collection
    get 'approve_all', on: :member
    get 'unapprove_all', on: :member
    get 'sort_published', on: :collection, action: :sort_by_published
    post '/publishing_target/:publishing_target', action: :publish_do, as: :publish_do
    post '/publish', action: :publish_page, as: :publish_page
    post 'unpublish/publishing_target/:publishing_target', action: :unpublish_do, as: :unpublish_do
    get 'filtered_search_result', on: :collection, action: :filtered_search_result, as: :filtered_search_result
  end
  get '/pages', to: 'page_folders#index'
  post '/restore_page', to: 'pages#restore', as: 'restore_page'

  resources :page_folders
  get 'publishing_events/:publishing_event/show', to: 'publishing_events#show'

  get 'asset_upload/upload', to: 'asset_upload#upload', as: 'upload_new_asset'
  post 'asset_upload/process', to: 'assets#create', as: 'handle_asset_upload'

  resources :teams, except: %i[update edit index show] do
    collection do
      put :update
      post :use_demo_data
    end
    member do
      put :update_salesforce_data
      put :update_preview_data
    end
  end
  get 'signup_team', to: 'teams#signup', as: :signup_team
  post 'register_team', to: 'teams#register_team', as: :register_team

  resources :password_resets
  get 'create_password/:id', to: 'password_resets#create_password', as: :create_password
  post 'password_resets/:id', to: 'password_resets#set_password', as: :set_password

  resources :translations

  resources :mail
  post 'create_broadcast_mail', to: 'mail#create_broadcast_mail', as: :create_broadcast_mail

  resources :page_modules do
    get 'versions', on: :member
    get 'restore_version/:version', on: :member, action: :restore_version, as: :restore_version
  end
  # Custom one for jsonEditor POST
  post 'page_modules/:id(.:format)', to: 'page_modules#update'

  get 'duplicate_page/:id(.:format)', to: 'pages#duplicate', as: 'duplicate_pages'

  get 'pages/:id/schedule/:schedule_id', to: 'pages#edit_schedule'
  get 'pages/:id/add_publishing_locale', to: 'pages#add_publishing_locale', as: 'add_publishing_locale'
  post 'pages/:id/update_page_publishing_locales',
       to: 'pages#update_page_publishing_locales', as: 'update_page_publishing_locales'
  get 'pages/:id/locales', to: 'pages#show_locales', as: 'show_page_publishing_locales'
  get 'pages/:id/approve_locale/:locale', to: 'pages#approve_locale', as: 'approve_locale'

  get 'pages/:id/export_translations', to: 'pages#export_translations', as: 'export_translations'
  get 'pages/:id/import_translations', to: 'pages#import_translations', as: 'import_translations'
  patch 'pages/:id/upload_translations', to: 'pages#upload_translations', as: 'upload_translations'

  post 'pages/:id/restore_version', to: 'pages#restore_version', as: 'restore_version'

  # Outputs a html of the entire page
  get 'pages/:id/:preview_locale/live-preview(.:format)', to: 'pages#live_preview_page', as: 'live_preview_page'

  # Public preview
  get 'pages/:id/:preview_locale/view-only-live-preview(.:format)',
      to: 'pages#view_only_live_preview_page', as: 'view_only_live_preview_page'
  # Public preview Schedule
  get 'pages/:id/:schedule_id/:preview_locale/view-only-schedule-preview(.:format)',
      to: 'pages#view_only_schedule_preview', as: 'view_only_schedule'
  # Outputs a content asset xml
  get 'pages/:id/render/xml', to: 'pages#render_xml', as: 'render_xml'
  # Publish content
  get 'pages/:id/publish_syncronous/:publishing_target', to: 'pages#publish_syncronous', as: 'publish_syncronous_page'
  # Async
  get 'pages/:id/publish/:publishing_target', to: 'pages#publish', as: 'publish_page'
  get 'pages/:id/unpublish/:publishing_target', to: 'pages#unpublish', as: 'unpublish_page'

  # Send to translation
  get 'pages/:id/send_to_translation_validation',
      to: 'pages#send_to_translation_validation', as: 'send_to_translation_validation'
  # Send validated translations to the API
  get 'pages/api/send_to_translation', to: 'pages#send_to_translation', as: 'send_to_translation'
  # Reset status
  get 'pages/reset_translation_status/:id(.:format)',
      to: 'pages#reset_translation_status', as: 'reset_translation_status'

  get 'pages/render_page_test/:id(.:format)', to: 'pages#render_page_test', as: 'render_page_test'

  get 'api/page_locales_for_attr_editor/:id', to: 'pages#locales_for_editor'

  namespace :api do
    # SCREENSHOTS
    get '/retrieve-missing-images-ids', to: 'screenshots#missing_images'
    get '/schedules_to_screenshot', to: 'screenshots#schedules_to_screenshot'
    post '/upload_image/:page_id', to: 'screenshots#upload_image'
    post '/upload_schedule_image/:schedule_id', to: 'screenshots#upload_schedule_image'
    post '/template_thumbnail', to: 'screenshots#template_thumbnail'
    # SESSIONS
    post 'login', to: 'sessions#login'
    # PASSWORDS
    post 'send_reset_email', to: 'password_resets#new'
    post 'reset_password', to: 'password_resets#reset'
    # TEAMS
    scope 'teams' do
      post 'create', to: 'teams#create'
      get '/team-settings', to: 'teams#settings'
      get '/retrieve_current_team', to: 'teams#retrieve_current_team'
      get '/check-team-setup', to: 'teams#check_team_setup'
      get '/salesforce_sites', to: 'teams#salesforce_sites'
      get '/team_sites', to: 'teams#team_sites'
      post '/import_sites', to: 'teams#import_sites'
      post '/clear_sites', to: 'teams#clear_sites'
    end
    # ASSETS
    post 'assets', to: 'assets#upload'
    # TEMPLATES
    get 'templates/download', to: 'templates#export'
    post 'templates/upload', to: 'templates#import'
    post 'templates/:id/image/upload', to: 'templates#upload_template_image', as: :template_image_upload

    resources :pages, only: [] do
      get :export_translations
      get :export_xml
      post :import_translations
    end
  end

  resources :site_groups
  resources :translation_viewer
  get 'translation_viewer', to: 'translation_viewer#index', as: 'show_translation_viewer'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
