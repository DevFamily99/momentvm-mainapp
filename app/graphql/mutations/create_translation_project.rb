require 'translation_service'
module Mutations
  class CreateTranslationProject < GraphQL::Schema::RelayClassicMutation
    field :message, String, null: false
    argument :provider, Types::TranslationProvider, required: true
    argument :title, String, required: true
    argument :deadline, String, required: true
    argument :locales, [String], required: true
    argument :page_ids, [ID], required: false

    def resolve(provider: nil, title: nil, deadline: nil, locales: nil, page_ids: [])
      t = TranslationService.new
      # get all translation ids form the pages
      translation_ids = []
      pages = Page.find(page_ids)
      pages.each do |page|
        page.page_modules.each { |pm| pm.body.scan(/loc::([0-9]*)/) { translation_ids << Regexp.last_match(1) } }
      end
      # create the translation Project
      project = TranslationProject.new
      current_user = context[:current_user]
      project.team_id = current_user.team_id
      project.title = title
      project.due_date = deadline
      project.provider = provider
      if provider == 'LW'
        pages.each do |page|
          page.send_to_translation_validation
          page.save!
        end
        project.save!
        CreateTranslationProjectWorker.perform_in(2.minutes, page_ids, locales, deadline, title, project.id,)
      elsif provider == 'GLOBALLINK'
        t.create_translation_project(
          name: title, due_date: deadline, target_locales: locales, translations_list: translation_ids
        ) do |response|
          raise GraphQL::ExecutionError, JSON.parse(response.body)['error'] if response.code != '200'

          project.submission_id = JSON.parse(response.body)['submission_id'].to_i
          project.save!
          return { message: 'Translation Project created.' } if project.save!
        end
      end
      { message: 'Project created' }
    end
  end
end
