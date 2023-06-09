module Teams
  # Creates an admin user based of the info of the team owner
  class CreateAdminUser < Actor
    input :team, allow_nil: false

    def call
      password = ([*('A'..'Z'), *('a'..'z'), *('0'..'9')] - %w[0 1 I O]).sample(8).join
      user = User.find_by_email(team.owner_email)
      unless user.present?
        user = User.create(
          email: team.owner_email,
          name: team.owner_firstname + ' ' + team.owner_lastname,
          password: password,
          password_confirmation: password,
          team: team
        )
        user.generate_password_create_token
      end
    end

    def rollback
      team.users.first.destroy
    end
  end
end
