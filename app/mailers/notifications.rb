class Notifications < ActionMailer::Base
  default from: 'support@libraryh3lp.com'

  def forgot_password to, password
    @password = password
    mail to: to, subject: 'Library a la Carte Message'
  end

  def forgot to, onid, section, url
    @onid = onid
    @section = section
    @url = url
    mail to: to, subject: "Library Tutorial Message"
  end

  def send_message to, from, body, subject
    @body = body
    mail to: to, from: from, subject: subject
  end

  def share_module to, from, mod, name
    @mod = mod
    @name = name
    mail to: to, from: from, subject: "Shared Library a la Carte Module"
  end

  def add_user to, from, pass, url
    @pass = pass
    @email = to
    @url = url
    mail to: to, from: from, subject: "Library a la Carte Message"
  end

  def add_pending_user to, from
    mail to: to, from: from, subject: "Library ala Carte Message"
  end

  def accept_nonsso_pending_user to, from, pass, url
    @pass = pass
    @email = to
    @url = url
    mail to: to, from: from, subject: "Your Library ala Carte Account has been approved"
  end

  def reject_pending_user to, from
    mail to: to, from: from, subject: "Your Library ala Carte Account has been denied"
  end

  def notify_admin_about_pending_user to, from, url
    @url = url
    mail to: to, from: from, subject: "Library ala Carte Message - Pending User Notification"
  end
end
