class UserMailer < ActionMailer::Base
  default from: 'support@libraryh3lp.com'

  def forgot_password email, password
    @password = password
    mail(to: email, subject: 'Library a la Carte Password')
  end
end
