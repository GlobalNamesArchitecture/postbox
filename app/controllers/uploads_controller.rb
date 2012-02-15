class UploadsController < ApplicationController

  def index
    @uploads = Upload.all
  end
  
  def show
    @upload = Upload.find_by_token(params[:id])
    queue_size = Resque.size(:dwc_importer)
    if queue_size > 0
      flash[:notice] = "There #{queue_size == 1 ? 'is' : 'are'} #{help.pluralize(queue_size, "job")} in the queue. You will also receive an email message when processing is complete."
    end
    if @upload.tree.status != 2
      @redirect_url = upload_path :id => @upload.token
      flash[:notice] = "Your tree is processing. You will receive an email message when it is complete."
      redirect_with_delay(@redirect_url, 10)
    else
      flash.delete :notice
    end
  end
  
  def new
    @upload = Upload.new
  end
  
  def create
    @upload = Upload.new(params[:upload])
    if @upload.save
      flash[:notice] = "Your file successfully uploaded and is in the queue for processing. This page will refresh every 10 seconds."
      Mailer.queue_email(@upload).deliver
      redirect_to upload_path :id => @upload.token
    else
      render :action => 'new'
    end
  end
  
  def destroy
    @upload = Upload.find(params[:id])
    if @upload.tree.nuke
      flash[:notice] = 'Tree successfully deleted'
      redirect_to :action => :new
    end
  end

end
