class UploadsController < ApplicationController

  def index
    @uploads = Upload.all
  end
  
  def show
    @upload = Upload.find(params[:id])
    queue_size = Resque.size(:dwc_importer)
    if queue_size > 1
      flash[:notice] = "There #{queue_size == 1 ? 'is' : 'are'} #{help.pluralize(queue_size, "job")} in the queue ahead of yours. You will also receive an email message when processing is complete."
    end
    if @upload.tree_id.nil?
      @redirect_url = upload_path @upload
      redirect_with_delay(@redirect_url, 15)
    end
  end
  
  def new
    @upload = Upload.new
  end
  
  def create
    @upload = Upload.new(params[:upload])
    if @upload.save
      flash[:notice] = "Your file successfully uploaded"
      Mailer.queue_email(@upload).deliver
      redirect_to upload_path @upload
    else
      render :action => 'new'
    end
  end

end
