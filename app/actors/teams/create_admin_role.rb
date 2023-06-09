module Teams
  # Generate default roles for a team
  class CreateAdminRole < Actor
    input :team, allow_nil: false

    def call
      user = team.users.first
      permissions =
        YAML.safe_load(File.read('./config/defaults/permissions.yml'))
      role = Role.find_or_create_by(team: team, name: 'Admin', body: permissions)
      user.roles << role  if role.present?
    end

    def rollback
      team.roles.destroy_all
    end
  end
end
