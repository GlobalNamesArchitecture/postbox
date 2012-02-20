class ContactsController < ApplicationController
  caches_page :new
  
  def new
    @contact = Contact.new
  end
  
  def create
    @contact = Contact.new(params[:contact])
    if verify_recaptcha(:model => @contact) && @contact.save
      flash[:notice] = "Thank you for having contacted us. We will be in touch."
      Mailer.contact_email(@contact).deliver
      redirect_to new_contact_path
    else
      if flash[:recaptcha_error]
        flash.delete :recaptcha_error
        flash[:warning] = "Incorrect reCaptcha"
      end
      render :action => 'new'
    end
  end
end
