class Notifications < ActionMailer::Base

  def forgot_password(to, pass, sent_at = Time.now)
    @subject    = "Library a la Carte ha"
    @body['pass']= pass
    @recipients = to
    @from       = ""
    @sent_on    = sent_at
    @headers    = {}
  end
  
   def send_url(to, from, body,  sent_at = Time.now)
    @subject    = "A new library course page"
    @body['body']= body
    @recipients = to
    @from       = from
    @sent_on    = sent_at
    @headers    = {}
  end
  
   def send_all(to, from, subject, body,  sent_at = Time.now)
    @subject    = subject
    @body['body']= body
    @recipients = to
    @from       = from
    @sent_on    = sent_at
    @headers    = {}
  end
  
  def share_page(to, from, page, sent_at = Time.now)
    @subject    = "Collaboration request for a course assignment page"
    @body['page']=page
    @recipients = to
    @from       = from
    @sent_on    = sent_at
    @headers    = {}
  end
  
  def share_guide(to, from, guide, sent_at = Time.now)
    @subject    = "Collaboration request for a subject guide"
    @body['guide']=guide
    @recipients = to
    @from       = from
    @sent_on    = sent_at
    @headers    = {}
  end
  
  def share_module(to, from, mod, sent_at = Time.now)
    @subject    = "Collaboration request for a guide module"
    @body['mod']=mod
    @recipients = to
    @from       = from
    @sent_on    = sent_at
    @headers    = {}
  end
  
end
