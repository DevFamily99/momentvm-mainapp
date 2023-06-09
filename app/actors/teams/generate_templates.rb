module Teams
  # Generate demo templates for a new team
  class GenerateTemplates < Actor
    input :team, allow_nil: false

    def call
      Dir.each_child(Rails.root.join('spec', 'fixtures', 'templates')) do |template_dir|
        template = Template.find_or_create_by!(
          name: template_dir.capitalize, team: team,
          body: File.read(Rails.root.join('spec', 'fixtures', 'templates', template_dir, 'template.html'))
        )
        template_image = File.open(Rails.root.join('spec', 'fixtures', 'templates', template_dir, 'image.png'), 'r')
        template.image.attach(
          io: template_image, filename: 'image.png', content_type: 'image/png'
        )
        TemplateSchema.find_or_create_by!(template: template, team: team, body: File.read(Rails.root.join('spec', 'fixtures', 'templates', template_dir, 'schema.yml')))
      end
    end

    def rollback
      team.templates.destroy_all
    end
  end
end
