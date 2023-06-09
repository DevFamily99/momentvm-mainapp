class TemplateSchema < ApplicationRecord
  belongs_to :template,  dependent: :destroy
  belongs_to :team, dependent: :destroy
  # serialize :body, Hash

  validate :yaml_schema_body
  validate :yaml_ui_schema

  has_paper_trail

  def self.by_team(current_user)
    TemplateSchema.where(team: current_user.team)
  end

  def yaml_schema_body
    YAML.load(body) if body
  rescue StandardError => e
    errors.add(:template_schema, 'is not in a valid YAML format.')
  end

  def yaml_ui_schema
    YAML.load(ui_schema) if ui_schema
  rescue StandardError => e
    errors.add(:ui_schema, 'is not in a valid YAML format.')
  end
end
