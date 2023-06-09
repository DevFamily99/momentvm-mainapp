class ApplicationMailer < ActionMailer::Base
  default from: 'cms@momentvm.com'
  layout 'mailer'

  def send_mail(recipient, subject, mailDetails, broadcast)

    if broadcast
      mail bcc: recipient, subject: subject do |format|
        format.html { render "mail_template", 
          :locals => { 
            :title => mailDetails[:title],
            :subtitle => mailDetails[:subtitle],
            :body => mailDetails[:body]
          } 
        }
      end
    else
      mail to: recipient, subject: subject do |format|
        format.html { render "mail_template", 
          :locals => { 
            :title => mailDetails[:title],
            :subtitle => mailDetails[:subtitle],
            :body => mailDetails[:body]
          } 
        }
      end
    end
  end


  def send_team_approved_mail(recipient, team, user)
    team = team;
    user = user;
    subject = "Welcome to MOMENTVM"
    body = render "team_approved", :locals => {team: team, user: user}

    mailDetails = {
      title: subject,
      subtitle: "Team approved", 
      body: body
    }

    send_mail(recipient, subject, mailDetails, false)
  end


  def send_register_team_mail(recipient)
    subject = "Your registration to MOMENTVM was successful"
    body = render "client_registration_pending"

    mailDetails = {
      title: "Successful registration",
      subtitle: "",
      body: body
    }

    send_mail(recipient, subject, mailDetails, false)
  end


  def send_register_team_mail_to_approver(recipient, team)
    team = team;
    subject = 'New registration for ' + team.name
    body = render "client_registration_info_for_approver", :locals => {:team => team}

    mailDetails = {
      title: "New registration",
      subtitle: "New registration for " + team.name,
      body: body
    }

    send_mail(recipient, subject, mailDetails, false)
  end

  def send_password_create_mail(user)
    user = user
    team = Team.find(user.team_id)
    subject = "Welcome to MOMENTVM"
    body = render "password_create", :locals => {:user => user, :team => team}

    mailDetails = {
      title: subject,
      subtitle: "", 
      body: body
    }

    send_mail(user.email, subject, mailDetails, false)
    
  end

  def send_password_reset_mail(user)
    @user = user
    subject = "Password reset"
    body = render "password_reset", :locals => {:user => user}

    mailDetails = {
      title: subject,
      subtitle: "Reset your password", 
      body: body
    }

    send_mail(user.email, subject, mailDetails, false)

  end


end
