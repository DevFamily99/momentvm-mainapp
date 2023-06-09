require 'uri'
require 'net/http'
require 'request'
require 'micro_service'

class TranslationService < MicroService
  def localize(html_body, locale)
    uri = URI.parse(Rails.configuration.translation_service[:url] + "/translate_body?locale=#{locale}")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.scheme == 'https')
    header = { 'Content-Type' => 'text/xml' }
    request = Net::HTTP::Post.new(uri.request_uri, header)
    request.basic_auth Rails.configuration.translation_service[:username],
                       Rails.configuration.translation_service[:password]
    request.body = html_body
    response = http.request(request)
    # unless response.code == "200"
    puts "TranslationService responded with: #{response.code}"
    #   puts "Error from Translation service: #{response.code}"
    #   return false
    # end
    self.body = response.body.force_encoding('UTF-8')
    yield nil, response.body.force_encoding('UTF-8')
    nil
  end

  # New graphql method
  def get_translation(id)
    # puts "service get translation gql #{id}"
    uri = URI.parse(Rails.configuration.translation_service[:url] + "/graphql")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.scheme == 'https')
    header = { 'Content-Type' => 'application/json' }
    request = Net::HTTP::Post.new(uri.request_uri, header)
    request.basic_auth Rails.configuration.translation_service[:username],
                       Rails.configuration.translation_service[:password]
    request.body = <<~GQL
    { "query" : "query{translation(id:#{id}) {id body}}" }
    GQL
    response = http.request(request)
    unless response.code == '200'
      puts "Error from Translation service: #{response.code}"
      return false
    end
    # puts response.body
    response
  end
  # Old deprecated
  def get_translation_old(id)
    puts "service get translation #{id}"
    uri = URI.parse(Rails.configuration.translation_service[:url] + "/translations/#{id}.json")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.scheme == 'https')
    header = { 'Content-Type' => 'application/json' }
    request = Net::HTTP::Get.new(uri.request_uri, header)
    request.basic_auth Rails.configuration.translation_service[:username],
                       Rails.configuration.translation_service[:password]
    response = http.request(request)
    unless response.code == '200'
      puts "Error from Translation service: #{response.code}"
      return false
    end

    self.body = response.body
    puts response.body
    response.body
  end

  def update_translation(translation_id, translation_body, current_user)
    uri =
      URI.parse(
        Rails.configuration.translation_service[:url] +
          "/api/team/#{current_user.team.id}/translation/#{translation_id}/update"
      )
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.scheme == 'https')
    header = { 'Content-Type' => 'application/json' }
    request = Net::HTTP::Post.new(uri.request_uri, header)
    request.basic_auth Rails.configuration.translation_service[:username],
                       Rails.configuration.translation_service[:password]
    request.body = translation_body.to_json.to_s
    response = http.request(request)
    unless response.code == '200'
      puts "Error from Translation service: #{response.code}"
      self.body = response.body
      yield 'error from TranslationService'
      return
    end
    self.body = response.body
    yield nil # no error
  end

  def delete_translation(id, current_user)
    uri =
      URI.parse(Rails.configuration.translation_service[:url] + "/api/team/#{current_user.team.id}/translation/#{id}")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.scheme == 'https')
    header = { 'Content-Type' => 'application/json' }
    request = Net::HTTP::Delete.new(uri.request_uri, header)
    request.basic_auth Rails.configuration.translation_service[:username],
                       Rails.configuration.translation_service[:password]
    response = http.request(request)
    unless response.code == '200' || response.code == '204'
      puts "Error from Translation service: #{response.code}"
      yield 'error from TranslationService'
      return
    end

    yield nil # no error
  end

  def new_translation(translation_body, current_user)
    req = Request.new
    req.send_request(
      url: Rails.configuration.translation_service[:url] + "/api/team/#{current_user.team.id}/translation/new",
      body: translation_body,
      header: { "Content-Type": 'application/json' },
      options: {
        type: :post,
        username: Rails.configuration.translation_service[:username],
        password: Rails.configuration.translation_service[:password]
      }
    ) do |response_code, response|
      if response_code != 200
        puts "error in translations_service, translation service status: #{response_code}"
        # puts response.body
        yield nil, "response code: #{response_code}"
        return
      end
      resp = JSON.parse(response.body)
      translation_id = resp['translation']['id']
      if resp.nil?
        puts 'Error translation service. Response nil :new_translation'
        render status: :internal_server_error, json: { error: 'Error translation service. Response nil :new_translation' }
        yield nil, 'Error translation service. Response nil :new_translation'
      end
      yield translation_id, nil
    end
  end

  # Page level
  # TODO LATER change so there is only one interface and everything
  # is done via the body of the request.
  # This has the benefit that the CMS service doesnt need to know what happens
  def send_to_translation(page_id:, body:, page_translation_status:)
    case page_translation_status
    when nil, 0
      puts "Validating translation, status: #{page_translation_status}"
      create_and_validate(
        page_id: page_id, body: body, page_translation_status: page_translation_status
      ) { |error, document_id, status| yield error, document_id, status }
    when 1
      puts 'already validated - skipping'
    when 2
      puts ':send_to_translation status 2'
    else
      puts ':send_to_translation undefined case'
    end
  end

  # Simple call abstracts everything that is specific to translation API implementation
  # Returns a status code
  # Yields error, document_id, new_page_translation_status
  def create_and_validate(page_id:, body:, page_translation_status:)
    uri = URI.parse(Rails.configuration.translation_service[:url] + '/api/send_to_translation_validation')
    # Create client
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.scheme == 'https')
    req = Net::HTTP::Post.new(uri.request_uri)
    # Add headers
    req.basic_auth Rails.configuration.translation_service[:username],
                   Rails.configuration.translation_service[:password]
    req.add_field 'Translation-Status', page_translation_status
    req.add_field 'Page-ID', page_id
    # Set body
    id_list = []
    body.scan(/loc::([0-9]+)/) { id_list << "loc::#{Regexp.last_match(1)}" }
    page = Page.find(page_id)

    id_list << page.title if page.title
    id_list << page.description if page.description
    id_list << page.keywords if page.keywords
    id_list << page.url if page.url

    req.body = id_list.join(',')
    puts "Sending #{req.body} to TranslationService"

    # Fetch Request
    res = http.request(req)
    case res.code.to_i
    when 200
      document_id = JSON.parse(res.body)['document_id']
      yield nil, document_id, 1
    else
      puts "Error in :create_and_validate. Response: #{res.body}"
      yield res.code, nil, page_translation_status
    end
  end

  # Fetches the details of a LW translation project
  def get_project(submission_id)
    req = Request.new
    req.send_request(
      url:
        Rails.configuration.translation_service[:url] +
          "/translation_requests/#{submission_id}/check_status",
      header: { 'Content-Type' => 'application/json' },
      options: {
        type: :get,
        json: true,
        username: Rails.configuration.translation_service[:username],
        password: Rails.configuration.translation_service[:password]
      }
    ) do |response_code, response|
      if response_code == 200
        self.body = response.body
        yield nil if block_given?
      else
        puts "Error from Translation service: #{response.code}"
        puts 'response.body'
        yield response if block_given?
      end
    end
  end

  def fetch_assignment(submission_id)
    req = Request.new
    req.send_request(
      url:
        Rails.configuration.translation_service[:url] +
          "/translation_requests/#{submission_id}/fetch_translations_for_req",
      header: { 'Content-Type' => 'application/json' },
      options: {
        type: :post,
        json: true,
        username: Rails.configuration.translation_service[:username],
        password: Rails.configuration.translation_service[:password]
      }
    ) do |response_code, response|
      if response_code == 200
        self.body = response.body
        yield nil if block_given?
      else
        puts "Error from Translation service: #{response.code}"
        puts 'response.body'
        yield response if block_given?
      end
    end
  end

  # Submits a translation project request to the TranslationService
  # This takes multiple documents (i.e. validated translations)
  # and packages them into a project
  # Yields error (nil or response)
  def send_translations_as_project(pages:, target_locales:, deadline:, project_title:)
    req = Request.new
    page_ids = []
    briefing_urls = []
    pages.each do |page|
      page_ids << page.translation_key
      briefing_urls <<
        ENV['DEFAULT_HOST'] +
        Rails.application.routes.url_helpers.view_only_live_preview_page_path(page, date: :all, preview_locale: :en)
    end
    puts "page ids: #{page_ids}"
    req.send_request(
      url: Rails.configuration.translation_service[:url] + '/api/create_project',
      body: {
        documents: page_ids,
        target_locales: target_locales,
        briefing: briefing_urls.join(', '),
        deadline: deadline,
        project_title: project_title
      },
      header: { 'Content-Type' => 'application/json' },
      options: {
        type: :post,
        json: true,
        username: Rails.configuration.translation_service[:username],
        password: Rails.configuration.translation_service[:password]
      }
    ) do |response_code, response|
      if response_code == 200
        self.body = response.body
        yield nil
      else
        puts "Error from Translation service: #{response.code}"
        puts 'response.body'
        yield response
      end
    end
  end

  # get the current status of a translation project
  # returns http response
  def check_translaiton_status(page_id)
    page = Page.find(page_id)
    req = Request.new
    req.send_request(
      url:
        Rails.configuration.translation_service[:url] +
          "/translation_requests/#{page.translation_project_id}/check_status",
      header: { 'Content-Type' => 'application/json' },
      options: {
        type: :get,
        json: true,
        username: Rails.configuration.translation_service[:username],
        password: Rails.configuration.translation_service[:password]
      }
    ) do |response_code, response|
      if response_code == 200
        self.body = response.body
        yield nil
      else
        puts "Error from Translation service: #{response.code}"
        puts 'response.body'
        yield response
      end
    end
  end

  # Search for a translation given a string query
  def search_for_translation(query:, team_id:)
    req = Request.new
    req.send_request(
      url:
        Rails.configuration.translation_service[:url] +
          "/api/translation/search?q=#{query}&team_id=#{team_id}",
      header: { 'Content-Type' => 'application/json' },
      options: {
        type: :get,
        json: true,
        username: Rails.configuration.translation_service[:username],
        password: Rails.configuration.translation_service[:password]
      }
    ) do |response_code, response|
      if response_code == 200
        self.body = response.body
        yield nil
      else
        puts "Error from Translation service: #{response.code}"
        puts 'response.body'
        yield response
      end
    end
  end

  # Trigger the TranslationService to check for translatios
  def check_for_finalized_translations
    send_request(
      url: Rails.configuration.translation_service[:url] + '/translation_requests/fetch_translations',
      options: {
        ssl: ssl_enabled?,
        username: Rails.configuration.translation_service[:username],
        password: Rails.configuration.translation_service[:password]
      }
    ) do |response_code, _response|
      case response_code
      when 200
        yield [1, 2]
      else
        yield []
      end
      return
    end
  end

  def create_team(team)
    req = Request.new
    req.send_request(
      url: Rails.configuration.translation_service[:url] + '/api/create_team',
      body: { id: team.id, name: team.name },
      header: { 'Content-Type' => 'application/json' },
      options: {
        type: :post,
        json: true,
        username: Rails.configuration.translation_service[:username],
        password: Rails.configuration.translation_service[:password]
      }
    ) do |response_code, response|
      self.body = response.body
      return true if response_code == 200

      return false
    end
  end

  # Creating a new translation project
  # uses the translations.com api
  def create_translation_project(name:, due_date:, target_locales:, translations_list:)
    req = Request.new
    req.send_request(
      url: Rails.configuration.translation_service[:url] + '/api/global_link/create_project',
      body: { name: name, due_date: due_date, target_locales: target_locales, translations_list: translations_list },
      header: { 'Content-Type' => 'application/json' },
      options: {
        type: :post,
        json: true,
        username: Rails.configuration.translation_service[:username],
        password: Rails.configuration.translation_service[:password]
      }
    ) do |response_code, response|
      if response_code == 200
        self.body = response.body
        yield response if block_given?
      else
        puts "Error from Translation service: #{response.code}"
        yield response if block_given?
      end
    end
  end

  def fetch_submission(submission_id)
    req = Request.new
    req.send_request(
      url:
        Rails.configuration.translation_service[:url] + '/api/global_link/submission_jobs?submission_id=' +
          submission_id,
      header: { 'Content-Type' => 'application/json' },
      options: {
        type: :get,
        json: true,
        username: Rails.configuration.translation_service[:username],
        password: Rails.configuration.translation_service[:password]
      }
    ) do |response_code, response|
      if response_code == 200
        self.body = response.body
        yield response if block_given?
      else
        puts "Error from Translation service: #{response.code}"
        yield response if block_given?
      end
    end
  end

  def fetch_translations(job_id)
    req = Request.new
    req.send_request(
      url: Rails.configuration.translation_service[:url] + '/api/global_link/fetch_translations',
      body: { job_id: job_id },
      header: { 'Content-Type' => 'application/json' },
      options: {
        type: :post,
        json: true,
        username: Rails.configuration.translation_service[:username],
        password: Rails.configuration.translation_service[:password]
      }
    ) { |_response_code, response| return response }
  end

  def ssl_enabled?
    return false if ENV['RENDER_SERVICE_SSL'].nil?

    ENV['RENDER_SERVICE_SSL'] == 'true'
  end
end
