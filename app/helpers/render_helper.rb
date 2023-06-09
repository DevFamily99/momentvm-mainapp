require "uri"
require "net/http"
require "json"

module RenderHelper


  # Mid level, renders a content asset xml
  def render_xml_from_locales(active_modules, all_templates)
    locales = ['de-DE', 'default']

    errors = []
    localized_modules = []
    locales.each do |locale|
      rendered_modules, render_errors = render_page_modules(:plain, active_modules, all_templates, locale)
      if render_errors.count != 0
        errors << render_errors
        next
      end
      # TODO
      locale = 'x-default' if locale == 'default'
      localized_modules << { locale: locale, body: rendered_modules }
    end

    return nil, errors if errors.count != 0

    actionController = ActionController::Base.new
    xml = actionController.render_to_string(partial: '/pages/xml-template',
                                            locals: {
                                              localized_modules: localized_modules
                                            })
    [xml, []]
  end

end