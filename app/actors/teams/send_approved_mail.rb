module Teams
  # Send a mail to the team owner
  class SendApprovedMail < Actor
    input :team, allow_nil: false

    def call
      ApplicationMailer.send_team_approved_mail(team.owner_email, team, team.users.first).deliver_later
    end
  end
end
