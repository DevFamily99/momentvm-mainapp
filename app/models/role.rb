class Role < ApplicationRecord
  has_and_belongs_to_many :users
  belongs_to :team
  serialize :user_id, Array
  # Deprecated to have real attributes
  #store :body, accessors: [:skills], coder: YAML
  validates :name, uniqueness: { scope: :team_id }, presence: true

  def raw_body
    read_attribute_before_type_cast('body')
  end

  # Workaround to mirror old roles behavior.
  # Clean this up in frontend
  def body
    {
      can_create_pages: self.can_create_pages,
      can_edit_pages: self.can_edit_pages,
      can_approve_pages:  self.can_approve_pages,
      can_see_advanced_menu:  self.can_see_advanced_menu,
      can_edit_templates:  self.can_edit_templates,
      can_see_language_preview:  self.can_see_language_preview,
      can_see_country_preview:  self.can_see_country_preview,
      can_unpublish_pages:  self.can_unpublish_pages,
      can_publish_pages:  self.can_publish_pages,
      can_edit_settings:  self.can_edit_settings,
      can_see_settings: self.can_see_settings,
      can_edit_all_modules_by_default: self.can_edit_all_modules_by_default,
      can_edit_module_permissions: self.can_edit_module_permissions,
      can_copy_modules: self.can_copy_modules,
      can_duplicate_page: self.can_duplicate_page
      }
  end

  # TODO Deprecate. Use an array instead
  def self.all_skills
    [
      { can_create_pages: false },
      { can_edit_pages: false },
      { can_approve_pages: false },
      { can_see_advanced_menu: false },
      { can_edit_templates: false },
      { can_see_language_preview: false },
      { can_see_country_preview: false },
      { can_unpublish_pages: false },
      { can_publish_pages: false },
      { can_edit_settings: false },
      { can_see_settings: false },
      { can_edit_all_modules_by_default: false },
      { can_edit_module_permissions: false },
      { can_copy_modules: false },
      { can_duplicate_page: false }
    ]
  end

  # Determine if the current role has a certain skill or not
  def has_skill?(searched_skill_name)
    # TODO Remove this!?
    return true if name == 'Admin'

    current_skills = body # YAML.load(self.body)
    skill_result = current_skills.select { |current_skill| current_skill.to_sym == searched_skill_name.to_sym }
    skill_result.keys.count.positive?
  end

  def self.by_team(current_user)
    Role.where(team_id: current_user.team_id)
  end

end
