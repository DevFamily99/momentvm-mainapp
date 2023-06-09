module Teams
  # Set the teams status as approved
  class SetTeamAsApproved < Actor
    input :team, allow_nil: false

    def call
      team.update!(approved: true)
    end
  end
end
