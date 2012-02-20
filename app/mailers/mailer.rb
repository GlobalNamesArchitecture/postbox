class Mailer < ActionMailer::Base
  default from: "admin@globalnames.org"
  
  def queue_email(upload)
    @upload = upload
    mail(:to => @upload.email, :subject => "Global Names PostBox upload") do |format|
      format.html
      format.text
    end
  end

  def preview_email(upload)
    @upload = upload
    mail(:to => @upload.email, :subject => "Global Names PostBox preview") do |format|
      format.html
      format.text
    end
  end
  
  def error_email(upload)
    @upload = upload
    mail(:to => @upload.email, :subject => "Global Names PostBox processing error") do |format|
      format.html
      format.text
    end
  end

  def contact_email(contact)
    @contact = contact
    mail(:from => @contact.email, :to => Postbox::Application.config.default_admin_email, :subject => "Global Names PostBox contact submission") do |format|
      format.html
      format.text
    end
  end
  
end
