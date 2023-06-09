# Convenience for retrieving settings
class SettingService
  ##### Locales

  # LiveEditor needs to know what type they are
  def self.locales_for_live_editor(user)
    locales = get_plain_locales(user).uniq
    locales_object = {}
    locales.each do |locale_object|
      locale = locale_object['locale']
      locales_object[locale] = {
        type: :string,
        format: :markdown
      }
    end
    locales_object
  end

  def self.get_default_locales
    locales_object = {}
    locales_object['default'] = {
      type: :string,
      format: :markdown
    }
    locales_object
  end

  # Gets an array of locales from Setting
  def self.get_plain_locales(user)
    mapping = load_from_db(user)
    return [] if mapping.empty?

    locales = []
    mapping['sites'].each do |site|
      site['locales'].each do |locale|
        locales << locale
      end
    end
    locales
  end

  # Gets an array of locales with names from Setting
  def self.get_named_locales(user)
    mapping = load_from_db(user)
    return [] if mapping.empty?

    locales = {}
    mapping['sites'].each do |site|
      site['locales'].each do |locale|
        locale_id = locale['locale']
        locales[locale_id] = locale['name']
      end
    end
    locales
  end

  # [{"name"=>"Germany", "id"=>"DE", "locales"=>[{"name"=>"German", "locale"=>"de"}], ...
  def self.get_sites(user)
    mapping = load_from_db(user)
    return [] if mapping.empty?

    sites = mapping['sites'].sort_by { |hsh| hsh['name'] }
    sites
  end

  def self.get_locales_for_site(publishingSite, user)
    mapping = load_from_db(user)
    return [] if mapping.empty?

    mapping['sites'].each do |site|
      return site['locales'] if site['id'] == publishingSite
    end
  end

  def self.locale_variants_from_site(site); end

  def self.get_allowed_countries_from_user(user)
    sites = get_sites(user)
    allowed_countries = user.allowed_countries

    all_locales_list = []
    sites.each do |site|
      site['locales'].each do |locale|
        all_locales_list << { name: locale['name'], locale: locale['locale'] } if !locale.key?('hidden') && allowed_countries && allowed_countries.include?((locale['locale']).to_s)

        if allowed_countries&.include?("#{locale['locale']}-#{site['id']}")
          lang_locale = "#{locale['locale']}-#{site['id']}"
          all_locales_list << { name: "#{locale['locale']} - #{site['name']}", locale: lang_locale }
        end
      end
    end
    unique_locales = []
    seen_keys = []

    # puts all_locales_list
    all_locales_list.each do |named_locale|
      locale = named_locale[:locale]
      unless seen_keys.include? locale
        seen_keys << locale
        unique_locales << named_locale
      end
    end
    # puts "Return: #{all_locales_list}"
    unique_locales
  end

  # ["ar-QA", "ar", "en-QA", "en", "ar-AE", "zh-CN", "zh", "
  def self.get_named_locale_variants(user)
    sites = get_sites(user)
    all_locales_list = []
    sites.each do |site|
      site['locales'].each do |locale|
        all_locales_list << { name: locale['name'], locale: locale['locale'] } unless locale.key?('hidden')
        lang_locale = "#{locale['locale']}-#{site['id']}"
        all_locales_list << { name: "#{locale['locale']} - #{site['name']}", locale: lang_locale }
      end
    end
    unique_locales = []
    seen_keys = []

    # puts all_locales_list
    all_locales_list.each do |named_locale|
      locale = named_locale[:locale]
      unless seen_keys.include? locale
        seen_keys << locale
        unique_locales << named_locale
      end
    end
    # puts "Return: #{all_locales_list}"
    unique_locales
  end

  # ["ar-QA", "ar", "en-QA", "en", "ar-AE", "zh-CN", "zh", "
  def self.get_sites_all_locale_variants(user)
    return get_sites_all_locale_variants_old(user) if ENV['FEATURE_TOGGLE_LOCALES_FROM_SITES'].nil?

    sites = Site.where(team: user.team)
    locales = []
    sites.each do |site|
      locales << site.locales.map(&:code)
    end
    locales.flatten
  end

  # Old
  def self.get_sites_all_locale_variants_old(user)
    sites = get_sites(user)
    all_locales_list = []
    return [] if user.allowed_countries.nil?

    sites.each do |site|
      site['locales'].each do |locale|
        lang_locale = "#{locale['locale']}-#{site['id']}"
        if user.allowed_countries_include?(locale['locale'])

          all_locales_list << locale['locale']
          # all_locales_list << lang_locale
        end

        next unless user.allowed_countries_include?(lang_locale)

        # all_locales_list << locale['locale']
        all_locales_list << lang_locale
      end
    end
    all_locales_list = all_locales_list.uniq
    # puts "Return: #{all_locales_list}"
    all_locales_list.sort
  end

  def self.live_editor_locales(user)
    dict = {}
    locales = get_sites_all_locale_variants(user)
    locales.each do |locale|
      dict[locale] = { type: :string, format: :markdown }
    end
    dict
  end

  # Remove
  def self.get_sites_and_locales(user)
    mapping = load_from_db(user)
    return [] if mapping.empty?

    sitesAndLocales = []

    mapping['sites'].each do |site|
      site['locales'].each do |locale|
        @locale = locale
        sitesAndLocales << "#{locale['locale']}-#{site['locale_id']}"

        sitesAndLocales << locale['locale'] unless sitesAndLocales.include? locale['locale']
      end
    end

    sitesAndLocales
  end

  # Returns locales in the format: locale-Site
  def self.get_locales_with_sites(user)
    mapping = load_from_db(user)
    return [] if mapping.empty?

    localesWithSite = []

    mapping['sites'].each do |site|
      site['locales'].each do |locale|
        localesWithSite << "#{locale['locale']}-#{site['locale_id']}"
      end
    end

    localesWithSite
  end

  def self.get_plain_sites(user)
    mapping = load_from_db(user)
    return [] if mapping.empty?

    sites = []
    mapping['sites'].each do |site, _value|
      sites << site
    end
    sites
  end

  def self.load_from_db(user)
    mapping = Setting.where(team_id: user.team_id).find_by_name('countries')
    if mapping.nil?
      []
    else
      mapping = YAML.load mapping.body
      mapping
    end
  end

  # Features

  def self.pages_show_language_preview(user)
    custom_settings = load_custom_settings_from_db(user)
    return false if custom_settings.nil?

    if custom_settings.key? 'pages'
      if custom_settings['pages'].key? 'languages-preview'
        return true if custom_settings['pages']['languages-preview'] == true
      end
    end
    false
  end

  # Image presets to resize images
  def self.load_image_sizes_from_db(team)
    mapping = Setting.where(team: team).find_by_name('image-sizes')
    if mapping.nil?
      nil
    else
      mapping = YAML.load mapping.body
      mapping
    end
  end

  def self.load_custom_settings_from_db(team)
    mapping = Setting.where(team: team).find_by_name('custom-settings')
    if mapping.nil?
      nil
    else
      mapping = YAML.load mapping.body
      mapping
    end
  end
end
