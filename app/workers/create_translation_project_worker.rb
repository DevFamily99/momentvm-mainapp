# Creates a translation project LW
class CreateTranslationProjectWorker
  include Sidekiq::Worker
  require 'translation_service'

  sidekiq_options retry: false

  # Note:
  # Its only possible to carry over strings and ints as args.

  # Submit a translation project from already validated pages
  def perform(page_ids, locales, deadline, title, translation_project_id)
    t = TranslationService.new
    translation_project = TranslationProject.find(translation_project_id)
    pages = Page.find(page_ids)
    t.send_translations_as_project(pages: pages, target_locales: locales, deadline: deadline, project_title: title) do |error|
      raise 'Error Creating the Translation Project' if error

      translation_project.submission_id = JSON.parse(t.body)['translation_request']
      translation_project.save!
    end
  end
end
