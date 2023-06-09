namespace :find do
  desc "TODO"
  task translation: :environment do
    translations = []
    pages =  [992937214, 992937212, 992937213]
    pages = Page.where(id: pages)
    pages.each do |p|
      body = p.page_modules.map {|m| m.body}
      body = body.join("")
      body.scan(/loc::[0-9]+/) do |match|
        translations << match
      end
    end
    puts translations.uniq.map{|t| t.gsub("loc::", "")}.join(",")
  end

end
