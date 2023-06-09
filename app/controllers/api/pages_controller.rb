module Api
  class PagesController < ApiController
    include TranslationsHelper
    require 'csv'
    include AssetsHelper

    skip_before_action :require_token, only: %i[export_translations export_xml]
    before_action :require_token_from_params, only: %i[export_translations export_xml]
    before_action :set_paper_trail_whodunnit, :set_current_user

    def import_translations
      @page = Page.find(params[:page_id])
      @page.last_imported_translation = DateTime.now 
      @page.save
      errors = []

      uploaded_io = File.read(params[:file].path)
      begin
        data = CSV.parse(uploaded_io, col_sep: ';')
        translationHash = {}

        data[0].each_with_index do |locale, index|
          next if index == 0

          translationHash[locale] = {}
        end
        translationHashKeys = translationHash.keys

        data.each_with_index do |row, index|
          next if index == 0

          translationId = row[0]
          row.each_with_index do |column, columnIndex|
            next if columnIndex == 0

            translationHash[translationHashKeys[columnIndex - 1]] = column || ''
          end
          ts = TranslationService.new
          ts.update_translation(translationId.to_i, translationHash, current_user) do |error|
            errors.push(error) if error
          end
        end
      rescue CSV::MalformedCSVError
        errors << 'Failed to import translation. The file must be a semicolon separated CSV file in UTF-8 format'
      rescue StandardError
        errors << 'Parsing file failed'
      end

      return render json: { message: errors.first }, status: 400 if errors.any?

      render json: { message: 'Translations successfully imported.' }
    end

    def export_xml
      @page = Page.find(params[:page_id])
  
      @approvedSites = []
      @publishingLocales = @page.publishing_locales.sort_by &:locale
      @publishingLocales.each do |pubLocale|
        localesForSite = SettingService.get_locales_for_site(pubLocale.locale, @current_user)
        if !pubLocale.approver_id.nil?
          @approvedSites << pubLocale.locale
        end
      end

  
      puts @approvedSites
      folder_assignments = @page.folder_assignments
      all_folder_assignments = YAML.safe_load(folder_assignments) if folder_assignments && !folder_assignments.empty?
      all_templates = Template.where(id: @page.page_modules.pluck(:template_id))
      active_modules = @page.page_modules.order(rank: :asc)
      active_modules_json = active_modules.each do |content_module|
        content_module.body = YAML.safe_load(content_module.body).to_json
      end
      ####### Publish images
      # Finds imaes and all their matches. Note: images can exist multiple times
      image_search_result = helpers.find_images_matches(active_modules, all_templates)
      #### Content
      images = Asset.where(name: image_search_result.pluck('name'))
      dynamic_images = helpers.dynamic_images_from(images, @current_user.team.image_settings)
      # render json: dynamic_images # image_search_result
      # return
      response = helpers.render_xml_publish(active_modules_json, all_templates, @approvedSites, dynamic_images, @current_user)
      response_body = JSON.parse(response.body)
  
      actionController = ActionController::Base.new
      xml = actionController.render_to_string(partial: '/pages/xml-template',
                                              locals: {
                                                page: @page,
                                                localized_modules: response_body['rendered_content']
                                              })
  
      send_data xml, filename: 'export.xml'
      return
      # ts = TranslationService.new
      # @page.title ? @page_title = JSON.parse(ts.get_translation(@page.title))["body"]: @page_title = nil
      # @page.description ? @page_description = JSON.parse(ts.get_translation(@page.description))["body"]: @page_description = nil
      # @page.keywords ? @page_keywords = JSON.parse(ts.get_translation(@page.keywords))["body"]: @page_keywords = nil
      # @page.url ? @page_url = JSON.parse(ts.get_translation(@page.url))["body"]: @page_url = nil
      # shape { <locale>: <localized text> }
      content_asset_document = response_body['rendered_content']
      errors = response_body['rendering_errors']
      # Will patch the content asset but also the category attribute
    end

    def export_translations
      @page = Page.find(params[:page_id])
      @page.last_sent_to_translation = DateTime.now
      @page.save
      csv_string = CSV.generate(col_sep: ';') do |csv|
        translation_locales = ['Localization ID']
        translationIds = []

        translationIds << @page.title if @page.title
        translationIds << @page.description if @page.description
        translationIds << @page.keywords if @page.keywords
        translationIds << @page.url if @page.url

        @page.page_modules.each do |page_module|
          page_module.body.scan(/loc::([0-9]*)/) do
            translationIds << Regexp.last_match(1)
          end
        end

        translationsArray = []

        translations = list_translations(translationIds) do |translations|
          translations.each do |translation|
            translationHash = {}
            translationLocalesAndValues = []
            translationHash['id'] = translation['id']
            translationHash['translations'] = []

            translation['body'].each_with_index do |locale, _index|
              translation_locales << locale[0] unless translation_locales.include? locale[0]
              translationLocalesAndValues << { locale[0] => locale[1] }
            end
            translationHash['translations'].concat(translationLocalesAndValues)
            translationsArray << translationHash
          end
          csv << translation_locales

          translationsArray.each do |translationHash|
            temp = []
            translation_locales.each_with_index do |locale, index|
              if index == 0
                temp << translationHash['id']
              else
                found = false
                translationHash['translations'].each do |hash|
                  if hash.keys.first == locale
                    temp << hash[hash.keys.first]
                    found = true
                  end
                end
                temp << '' unless found
              end
            end
            csv << temp
          end
        end
      end

      send_data csv_string, filename: "translation_export_#{Time.now.getutc}.csv"
    end

    private

    def require_token_from_params
      token = request.params[:apiToken]
      return render json: { error: 'Auth token missing' }, status: 403 unless token

      begin
        decoded_token = JWT.decode token, Rails.application.credentials.secret_key_base, true, { algorithm: 'HS512' }
        @current_user = User.find(decoded_token[0]['user_id'])
      rescue StandardError => e
        render json: { error: 'Token verification error' }, status: 403
      end
    end

    def set_current_user
      current_user
    end
  end
end
