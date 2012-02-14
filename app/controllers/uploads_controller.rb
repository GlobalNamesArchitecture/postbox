class UploadsController < ApplicationController

  def index
    @uploads = Upload.all
  end
  
  def show
    @upload = Upload.find(params[:id])
    @statistics = nil
    queue_size = Resque.size(:dwc_importer)
    if queue_size > 0
      flash[:notice] = "There #{queue_size == 1 ? 'is' : 'are'} #{help.pluralize(queue_size, "job")} in the queue. You will also receive an email message when processing is complete."
    end
    if @upload.tree.status != 2
      @redirect_url = upload_path @upload
      redirect_with_delay(@redirect_url, 10)
    else
      @statistics = @upload.tree.statistics
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
      redirect_to upload_path @upload
    else
      render :action => 'new'
    end
  end

end
