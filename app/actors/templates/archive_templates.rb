module Templates
  # Look through the templates related page modules and archive the templates that haven't been updated in 12 months
  class ArchiveTemplates < Actor
    output :archived_count
    def call
      active_template_ids = Template.joins(:page_modules).where('page_modules.updated_at > ?', 1.year.ago).distinct.pluck(:id)
      inactive_templates = Template.where.not(id: active_template_ids)
      self.archived_count = inactive_templates.count
      inactive_templates.update(archived: true)
    end
  end
end
