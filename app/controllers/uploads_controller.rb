require 'resque_scheduler'

class UploadsController < ApplicationController
  caches_page :new

  def index
    page = (params[:page]) ? params[:page] : 1
    @uploads = Upload.includes([:tree, :metadata])
                           .where(:trees => { :status => 3})
                           .paginate(:page => page, :per_page => 15)
                           .order("metadata.updated_at ASC")
  end
  
  def show
    @upload = Upload.find_by_token!(params[:id])
    redirect_url = upload_path :id => @upload.token
    case @upload.tree.status
      when 0
        queue_status = nil
        queue_size = Resque.size(:dwc_importer)
        if  queue_size > 0
          queue_status = "There #{queue_size == 1 ? 'is' : 'are'} #{help.pluralize(queue_size, "job")} in the queue. "
        end
        flash[:notice] = "Your file is queued for processing. #{queue_status}This page will refresh every 15 seconds."
        redirect_with_delay(redirect_url, 15)
      when 1
        flash[:notice] = "Your tree is now processing. This page will refresh every 15 seconds."
        redirect_with_delay(redirect_url, 15)
      when 2
        flash.delete :notice
        flash[:warning] = "Your preview will be cleared in 10 days unless you finalize your submission."
      when 99
        flash.delete :notice
        flash[:warning] = "There was a problem with your file. Check your meta.xml and/or your core file."
    end
  end
  
  def new
    @upload = Upload.new
  end
  
  def create
    @upload = Upload.new(params[:upload])
    if @upload.save
      Resque.enqueue(Upload, @upload.id)
      Resque.enqueue_in(10.days, Tree, @upload.tree.id)
      Mailer.queue_email(@upload).deliver
      redirect_to upload_path :id => @upload.token
    else
      render :action => 'new'
    end
  end

end
