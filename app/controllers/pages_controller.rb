# frozen_string_literal: true

class PagesController < ApplicationController
  require 'micro_service'
  require 'content_renderer'
  require 'translation_service'
  require 'publishing_service'
  require 'setting_service'
  require 'publishing_locale'
  require 'category_reference_helper'
  require 'file_upload_worker'
  require 'page_manifest_worker'
  require 'page_module_worker'
  require 'schedule_publish_worker'
  require 'csv'

  before_action :set_page, only: %i[view_only_live_preview_page view_only_schedule_preview reset_translation_status send_to_translation_validation view_only_live_preview_page view_only_schedule_preview]
  # this is used for the languageWire page preview, so it needs to be public
  skip_before_action :require_login, if: -> { %w[view_only_live_preview_page view_only_schedule_preview].include?(action_name) }
  skip_before_action :verify_authenticity_token, only: %i[view_only_live_preview_page view_only_schedule_preview]
  # GET /pages
  # GET /pages.json

  # renders the proccessed page from the render service
  def view_only_schedule_preview
    schedule = Schedule.find(params[:schedule_id])
    return render json: :error if schedule.nil?

    if illegal_params(params)
      render json: :error
      return
    end
    preview_locale = params[:preview_locale]
    all_templates = Template.where(id: @page.page_modules.pluck(:template_id))
    preview_additive = @page.team.preview_render_additive || ''
    schedule_modules = schedule.valid_modules
    images = helpers.find_images(schedule_modules, all_templates, @page.team)
    render_response = helpers.render_preview(schedule_modules, all_templates, preview_locale, images).body.force_encoding('UTF-8')
    cached_wrapper = helpers.get_page_wrapper(@page)

    return render inline: '<h1>Error:</h1><p>The widget placeholder cannot be found. Check the selector in team settings</p>' if cached_wrapper.nil?

    @decorated_page = cached_wrapper.gsub('__WIDGET__', preview_additive + render_response)
    respond_to do |format|
      format.json { render json: { content: @decorated_page }, layout: 'live_editor' }
      format.html { render inline: @decorated_page, layout: 'live_editor' }
    end
  end

  # renders the proccessed page from the render service - CLASSIC
  def view_only_live_preview_page
    if illegal_params(params)
      render json: :error
      return
    end
    preview_additive = @page.team.preview_render_additive || ''
    preview_locale = params[:preview_locale]
    return if locale.nil? || locale =~ /not/

    active_modules = @page.page_modules.order(rank: :asc)
    nested_modules = active_modules.map(&:page_modules).flatten
    all_templates = Template.where(id: nested_modules.concat(active_modules).map(&:template_id))
    # Let the render service find image placeholders and find the Asset objects for it
    images = helpers.find_images(nested_modules.concat(active_modules), all_templates, @page.team)
    render_response = helpers.render_preview(active_modules, all_templates, preview_locale, images).body.force_encoding('UTF-8')
    # Get a wrapper of the page to pluck the rendered content into
    cached_wrapper = helpers.get_page_wrapper(@page)
    return render inline: '<h1>Error:</h1><p>The widget placeholder cannot be found. Check the selector in team settings</p>' if cached_wrapper.nil?

    @decorated_page = cached_wrapper.gsub('__WIDGET__', preview_additive + render_response)

    respond_to do |format|
      format.json { render json: { content: @decorated_page }, layout: 'live_editor' }
      format.html { render inline: @decorated_page, layout: 'live_editor' }
    end
  end

  # Sends a page to validation
  # Returns a document id
  def send_to_translation_validation
    unless @page.translation_status.nil?
      redirect_to @page, alert: 'This page has been sent already'
      return
    end
    @page.send_to_translation_validation do |error|
      unless error.nil?
        redirect_to @page, alert: 'Validation failed'
        return
      end
    end
    if @page.save
      redirect_to @page, notice: 'Sent for validation'
    else
      redirect_to @page, alert: 'Saving pages after validation failed'
    end
  end

  # Send all the validated translations
  def send_to_translation
    pages = Page.by_team(current_user).where(translation_status: 1)
    if pages.count == 0
      redirect_to pages_path, notice: 'No translations to send'
      return
    end
    target_languages = Setting.by_team(current_user).find_by(name: 'target-languages')
    if target_languages.nil?
      redirect_to pages_path, alert: 'Target languages is missing. Create it in settings.'
      return
    else
      target_languages = YAML.safe_load(target_languages.body)
    end
    service = TranslationService.new
    service.send_translations_as_project(pages: pages, target_locales: target_languages) do |error|
      if error.nil? == false
        redirect_to pages_path, alert: "Errors: #{error.message}. Check if some of the translations contain errors"
        return
      end
      pages.each do |page|
        page.translation_status = 2
        page.save
      end
      puts "created for #{pages}"
      redirect_to pages_path, notice: "Project has been created for pages #{pages.pluck(:name).join(', ')}"
    end
  end

  def reset_translation_status
    @page.translation_status = nil
    @page.translation_key = nil
    if @page.save
      redirect_to page_path(@page), notice: 'Translation status reset'
    else
      redirect_to page_path(@page), alert: 'Error resetting Translation status'
    end
  end

  private

  def check_token
    return true if Rails.env.development?

    request_key = request.headers['SCREENSHOT-SERVICE-KEY']
    request_key && request_key == ENV['SCREENSHOT-SERVICE-KEY']
  end

  def illegal_params(params)
    return true if params.key? :rel
    return true if params.key? :autoplay

    false
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_page
    @page = if params[:id].nil?
              Page.find(params[:page_id])
            else
              Page.find(params[:id])
            end
    # screenshot_bot needs to take screenshots for all teams
    return if check_token

    if current_user && current_user.team != @page.team
      redirect_to home_index_path, alert: 'Not allowed'
      nil
    end
  end

  def require_permission
    unless current_user
      redirect_to login_path
      return
    end
    redirect_to root_path if current_user.team != @page.team
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def page_params
    params.require(:page).permit(
      :page_folder_id, :tag, :publish_assets,
      :context, :is_searchable, :schedule, :context_type,
      :name, :translation_status, :translation_key, :folder_assignments,
      :term, :title, :description, :keywords, :url, :thumbnail, :team_id
    )
  end
end
