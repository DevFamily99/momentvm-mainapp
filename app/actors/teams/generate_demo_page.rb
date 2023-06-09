module Teams
  # Generate a demo page with demo page modules and preview
  class GenerateDemoPage < Actor
    input :team, allow_nil: false

    def call
      page_root_folder = team.page_folders.where(page_folder_id: nil).first 
      page = Page.find_or_create_by!(team: team, page_folder: page_root_folder, name: 'Demo Page', context_type: 'supports_schedules')
      GenerateDemoPageModules.call(page: page, team: team)
      GenerateDemoPreview.call(pageId: page.id)
    end

    def rollback
      team.pages.destroy_all
    end
  end
end
