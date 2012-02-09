class Mailer < ActionMailer::Base
  default from: "admin@globalnames.org"
  
  def queue_email(upload)
    @upload = upload
    mail(:to => @upload.email, :subject => "Global Names Upload") do |format|
      format.html
      format.text
    end
  end

  def preview_email(upload)
    @upload = upload
    mail(:to => @upload.email, :subject => "Global Names Preview") do |format|
      format.html
      format.text
    end
  end
end
