# Render modules
class ContentRenderer

  require 'micro_service'
  require 'render_service'
  require 'proxy_service'
  require 'setting_service'
  require 'translation_service'

  attr_accessor :flags

  def initialize
    self.flags = {}
  end

  # Returns:
  # - page, needed for preview snippet current_page
  # - errors
  def render_live_editor_page_old(active_modules, all_templates, locale, page, locales)
    all_errors = []
    render_page_modules(:plain, active_modules) do |errors, rendered_active_modules|
      all_errors << errors unless errors.nil?
      wrap_modules_markers(rendered_active_modules, active_modules) do |wrapped_page|
        replace_image_urls(:plain, wrapped_page) do |processed_page|
          translate_modules(processed_page, locale) do |tr_errors, translated_page|
            all_errors << tr_errors unless tr_errors.nil?
            if self.flags[:view_only]
              # TODO Clean this up later
              translated_page = translated_page.gsub(/(href=\"|src=\"|url\(\")((.*?)\?\$staticlink\$)/) do
                staging_url = "https://staging-web-stokke.demandware.net/on/demandware.static/-/Library-Sites-StokkeSharedLibrary/default/"
                return_string = "#{$1}#{staging_url}#{$3}"
                return_string
              end
              decorate_rendered_modules(translated_page, "") do |dec_errors, page|
                all_errors << dec_errors unless dec_errors.nil?
                yield all_errors.flatten, page
              end
            else
              render_live_preview_helper(all_templates, active_modules, locale, page, locales) do |rendered_helper|
                decorate_rendered_modules(translated_page, rendered_helper) do |dec_errors, page|
                  all_errors << dec_errors unless dec_errors.nil?
                  yield all_errors.flatten, page
                end
              end
            end
          end
        end
      end
    end
  end


  # in the form of [ "de" => "<div..."}, ...]
  # The content asset carries the velocity code
  def render_content_asset_document(locales, active_modules, all_templates)
    all_errors = []
    content_asset_document = {}
    locales.each do |locale|
      render_page_modules(:with_scheduling, active_modules) do |errors, rendered_active_modules|
        all_errors << errors unless errors.nil?
        wrap_modules_markers(rendered_active_modules, active_modules) do |wrapped_page|
          replace_image_urls(:with_scheduling, wrapped_page) do |processed_page|
            translate_modules(processed_page, locale) do |tr_errors, translated_page|
              all_errors << tr_errors unless tr_errors.nil?
              content_asset_document[locale] = translated_page
            end
          end
        end
      end
    end
    yield all_errors.flatten, content_asset_document
  end


  ######## Low level apis

  # Uses RenderService for templating all the modules
  # Returns:
  # - errors, if any occured, as an array
  # - rendered_modules, only the rendered modules themselves
  # - rendering_mode: :with_scheduling will be passed to the RenderingService
  #                   which will add a velocity scheduling markup
  #                   :plain will not
  def render_page_modules(rendering_mode, active_modules)
    errors = []
    # Check module time stamp validity
    rendered_active_modules = []
    active_modules.each do |page_module|
      render_service = RenderService.new
      render_service.render_page_module(rendering_mode, page_module) do |error, page_module|
        if error.nil?
          rendered_active_modules << page_module
        else
          errors << error
        end
      end
    end
    yield errors, rendered_active_modules
    return
  end


  # Localize the modules
  # Yields errors, translated_modules
  # rendered_modules type String
  def translate_modules(rendered_modules, locale)
    translationService = TranslationService.new
    translated_modules = []
      translationService.localize(rendered_modules.to_s, locale) do |error, translated_modules|
        if error.nil?
          yield nil, translated_modules
          return
        else
          yield error, nil
          return
        end
      end
  end

  # Wrap html modules in marker divs so that we know the ID, order and so on
  # Yields one big text
  # Takes array
  def wrap_modules_markers(rendered_modules, active_modules)
    actionController = ActionController::Base.new
    rendered_modules = actionController.render_to_string(
      partial: '/pages/preview-rendered-page-modules',
      locals: { page_modules: active_modules, # We need the module objects and the rendered form
                rendered_active_modules: rendered_modules
                })
    yield rendered_modules
    return
  end

  # The snippet that contains JS etc for Live Preview
  # Renders the live editor preview helper, see _preview-helper-snippet for more details
  # yields the rendered helper
  def render_live_preview_helper(all_templates, active_modules, locale, page_id, locales)
    modulesData = [] # For the JSON array that holds the modules
    active_modules.each do |m|
      next if m.body.nil?
      modulesData << { id: m.id, body: YAML.safe_load(m.body) }
    end
    actionController = ActionController::Base.new
    rendered_helper = actionController.render_to_string(partial: '/pages/preview-helper-snippet', locals: {
                                                          all_templates: all_templates, # For select when creating new modules
                                                          modulesData: modulesData, # For rendering the JSON containing the data for the editor
                                                          current_page: page_id,
                                                          localeLinks: generateStgPreviewURLs(locales, page_id),
                                                          locale: locale,
                                                          all_locales: SettingService.locales_for_live_editor(current_user)
                                                        })
    yield rendered_helper
    return
  end


  def generateStgPreviewURLs(locales, page_id)
    # TODO 
   # context = Page.find(page_id).context
   # context_type =  Page.find(page_id).context_type
   # localeLinks = []
   #
   #  locales.each do |locale|
   #
   #    locale_string = "#{locale['site']}/#{locale['locale']}"
   #    categorySearch = "search?cgid=#{context}"
   #    assetSearch = "#{context}.html"
   #
   #    localeLink = "https://staging-web-stokke.demandware.net/s/#{locale_string}/#{context_type == 'category' ? categorySearch : assetSearch}"
   #
   #    localeLinks << {name: locale["name"], link: localeLink}
   #  end
   #  return localeLinks
   return []

  end

  # Replaces image urls for live preview or rendering
  def replace_image_urls(rendering_mode, page)
    page = "#{page}" # Dirty hack because ActionView::OutputBuffer wont conert to string
    case rendering_mode
    when :plain
      puts 'Image rendering :plain mode'
      page = page.gsub(/img::(.*?)::/) do
        asset = Asset.find_by_name($1)
        return_string = 'notFound.png'
        return_string = asset.image.url(:high) unless asset.nil?
        return_string
      end

      page = page.gsub(/mobileImg::(.*?)::/) do
        asset = Asset.find_by_name($1)
        return_string = 'notFound.png'
        return_string = asset.image.url(:medium) unless asset.nil?
        return_string
      end

      page = page.gsub(/tabletImg::(.*?)::/) do
        asset = Asset.find_by_name($1)
        return_string = 'notFound.png'
        return_string = asset.image.url(:large) unless asset.nil?
        return_string
      end


      yield page
      return
    when :with_scheduling
      page = page.gsub(/img::(.*?)::/) do
        asset = Asset.find_by_name($1)
        return_string = 'notFound.png'
        if asset != nil
         return_string = "#{ENV['WEBDAV_FOLDER']}/#{asset.image.instance.image_file_name}?$staticlink$"
        end
        return_string
      end
      page = page.gsub(/mobileImg::(.*?)::/) do
        asset = Asset.find_by_name($1)
        return_string = 'notFound.png'
        if asset != nil
          return_string = "#{ENV['WEBDAV_FOLDER']}/m_#{asset.image.instance.image_file_name}?$staticlink$"
        end
        return_string
      end

      page = page.gsub(/tabletImg::(.*?)::/) do
        asset = Asset.find_by_name($1)
        return_string = 'notFound.png'
        if asset != nil
          return_string = "#{ENV['WEBDAV_FOLDER']}/l_#{asset.image.instance.image_file_name}?$staticlink$"
        end
        return_string
      end

      yield page
      return
    when :none
      yield page
      return
    else
      yield "Error. No mode specified" # No mode was specified
      return
    end
  end

  # Calls ProxyService for decorating with a page wrapper
  def decorate_rendered_modules(rendered_modules, rendered_helper)
    errors = []
    # Proxy decorator step
    proxy = ProxyService.new
    proxy.get_page do |error, page|
      if error != nil
        yield error, page
        return
      end
      page = page.gsub('__WIDGET__', rendered_modules) # Replace the placeholder with the rendered content
      page = page.gsub('</body>', rendered_helper + '</body>'.html_safe) # Insert the helper at the end of the body
      yield error, page
    end
  end
end
