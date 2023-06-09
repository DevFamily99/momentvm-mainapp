require 'uri'
require 'net/http'
require 'json'
require 'render_service_helper'
module PagesHelper
  # Add a page view
  def add_page_view_for(page, current_user)
    return if current_user.nil?

    current_user.page_views.last.destroy unless current_user.page_views.count < 10
    # Dont add the same page twice
    if current_user.page_views.count != 0
      return if current_user.page_views.last.page == page
    end
    already_visited_page = current_user.page_views.where(page: page)
    unless already_visited_page.nil?
      # If the current page is in the history, remove it there and add
      # it to the top again
      current_user.page_views.delete(already_visited_page)
    end
    page_view = PageView.new
    page_view.user = current_user
    page_view.page = page
    puts "Error saving page view for #{page}" unless page_view.save
  end

  def page_was_published(page)
    last_published = page.page_activities.where(activity_type: :publish_successful).last(1)
    if last_published.empty?
      nil
    else
      last_published.first
    end
  end

  # Asks the render service to render a html preview
  def render_preview(active_modules, all_templates, preview_locale, images)
    req = Request.new
    sites = if current_user
              SettingService.get_sites(current_user)
            else
              YAML.load(Setting.find_by(name: 'countries').body)['sites']
            end
    preview_body = {
      modules: active_modules,
      templates: all_templates,
      nested_modules: active_modules.map(&:page_modules).flatten,
      images: images,
      sites: sites,
      configuration: {
        locale: preview_locale,
        site: 'DE'
      }
    }
    p preview_body
    req.send_request(
      url: ENV.fetch('RENDER_SERVICE_URL') + '/preview',
      body: preview_body,
      options: {
        type: :post,
        json: true,
        username: ENV.fetch('RENDER_SERVICE_USERNAME'),
        password: ENV.fetch('RENDER_SERVICE_PASSWORD')
      }
    ) do |_response_code, response|
      return response
    end
  end

  # For download XML
  def render_xml_publish(active_modules, all_templates, countries, images, current_user)
    req = Request.new
    preview_body = {
      modules: active_modules,
      templates: all_templates,
      images: images,
      sites: SettingService.get_sites(current_user),
      configuration: {
        countries: countries,
        velocity: true
      }
    }
    req.send_request(
      url: ENV.fetch('RENDER_SERVICE_URL') + '/render_page',
      body: preview_body,
      options: {
        type: :post,
        json: true,
        username: ENV.fetch('RENDER_SERVICE_USERNAME'),
        password: ENV.fetch('RENDER_SERVICE_PASSWORD')
      }
    ) do |_response_code, response|
      return response
    end
  end

  # Retrieves the page wrapper from the proxy service
  def get_page_wrapper(page)
    @selector = ''
    @url = ''
    proxy_service = ProxyService.new
    page_context = page.page_context
    # Try to find a value
    url_from_context = page_context&.preview_wrapper_url
    selector_from_context = page_context&.selector
    # Fall back to team settings definitions if page doenst have a valid context
    if url_from_context.blank? || selector_from_context.nil? || selector_from_context.empty?
      @url = page.team.preview_wrapper_url
      @selector = page.team.selector
    else
      @url = url_from_context
      @selector = selector_from_context
    end
    # if nothing is set use the default momentvm settings
    @url ||= Rails.application.credentials.dig(ENV['CURRENT_INSTANCE']&.to_sym || :local, :mainapp, :momentvm_preview_url)
    @selector ||= Rails.application.credentials.dig(ENV['CURRENT_INSTANCE']&.to_sym || :local, :mainapp, :preview_selector)

    proxy_service.get_page_cached(@url, @selector) do |_error, page_wrapper|
      return page_wrapper
    end
  end
end
