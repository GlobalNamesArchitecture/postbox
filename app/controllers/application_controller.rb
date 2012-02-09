class ApplicationController < ActionController::Base
  protect_from_forgery

  rescue_from ActiveRecord::RecordNotFound, :with => :render_404
 
  def help
    Helper.instance
  end
  
  def render_404
    render :file => "#{Rails.root}/public/404.html",  :status => 404
  end

 
  class Helper
    include Singleton
    include ActionView::Helpers::TextHelper
  end
end
