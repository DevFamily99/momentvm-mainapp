module TranslationsHelper

  def list_translations(list)
    if list.class == "String"
      list = list.split(",").uniq
      list = list.map {|item| item.to_int}
    end
    req = Request.new
    req.send_request(
      url: Rails.configuration.translation_service[:url] + "/api/translations/list",
      body: {
        translations: list
      },
      options: {
        type: :post,
        username: Rails.configuration.translation_service[:username],
        password: Rails.configuration.translation_service[:password]
      }
    ) do |response_code, response|
      if response_code != 200
        puts "error in translations_helper, translation service status: #{response_code}"
        #puts response.body
        yield nil
      end
      resp = JSON.parse(response.body)
      if resp.nil?
        puts "Error: TranslationsHelper list_translations resp is nil"
        yield nil
      end
      translations = resp["translations"]
      yield translations
    end
  end
end