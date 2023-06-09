class Setting < ApplicationRecord
  belongs_to :team

  validate :valid_yaml_body

  def self.by_team(current_user)
    Setting.where(team_id: current_user.team_id)
  end

  def valid_yaml_body
    YAML.load(body)
  rescue StandardError => e
    errors.add(:body, 'is not in a valid YAML format.')
  end
end
