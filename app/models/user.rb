require 'jwt'

class User < ApplicationRecord
  authenticates_with_sorcery!

  validates :password, length: { minimum: 3 }, if: -> { new_record? || changes[:crypted_password] }
  validates :password, confirmation: true, if: -> { new_record? || changes[:crypted_password] }
  validates :password_confirmation, presence: true, if: -> { new_record? || changes[:crypted_password] }
  validates :email, uniqueness: true, presence: true

  has_many :page_activities, dependent: :delete_all
  has_and_belongs_to_many :roles
  has_many :page_views, dependent: :destroy
  belongs_to :team, optional: true
  before_create { generate_token(:auth_token) }
  has_many :publishing_manifests, dependent: :destroy

  serialize :role, Array

  after_create do
    team = Team.find_by(owner_email: email)
    unless team.nil?
      role = Role.create(name: 'default', body: { 'can_edit_settings' => 'yes', 'can_see_settings' => 'yes' }, team_id: team_id)
      roles << role
    end
  end

  def allowed_countries_include?(country)
    return false if allowed_countries.nil?

    if allowed_countries.include? country
      true
    else
      false
    end
  end

  def send_password_create
    generate_token(:reset_password_token)
    self.reset_password_email_sent_at = Time.zone.now
    save!
    ApplicationMailer.send_password_create_mail(self).deliver_later
  end

  def generate_password
    ([*('A'..'Z'), *('a'..'z'), *('0'..'9')] - %w[0 1 I O]).sample(8).join
  end

  def generate_password_create_token
    generate_token(:reset_password_token)
    self.reset_password_email_sent_at = Time.zone.now
    save!
  end

  def send_password_reset
    generate_token(:reset_password_token)
    self.reset_password_email_sent_at = Time.zone.now
    save!
    ApplicationMailer.send_password_reset_mail(self).deliver
  end

  def generate_token(column)
    begin
      self[column] = SecureRandom.urlsafe_base64
    end while User.exists?(column => self[column])
  end

  def skills
    skills = {}
    Role.all_skills.each do |skill_hash|
      key = skill_hash.keys.first
      value = skill_hash[key]
      no_roles_with_skill = self.roles.where(key == true)
      skills[key] = true if no_roles_with_skill.count > 0
    end
    # user_roles = app_admin? ? team.roles : roles
    skills
  end

  def has_skill?(skill_name)
    return true if app_admin?

    matches = roles.select { |role| role.has_skill?(skill_name.to_sym) }

    matches.count.positive?
  end

  def self.by_team(current_user)
    User.where(team_id: current_user.team_id)
  end

  def is_admin?
    roles.find_by_name('Admin') ? true : false || app_admin
  end

  def generate_api_token
    payload = { user_id: id, email: email, team_name: team.name, skills: skills, app_admin: app_admin }
    JWT.encode payload, Rails.application.credentials.secret_key_base, 'HS512'
  end
end
