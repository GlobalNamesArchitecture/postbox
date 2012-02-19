class MetadataController < ApplicationController
  def show
  end

  def edit
    @metadata = Metadata.find(:all, :limit => 1, :joins => :upload, :conditions => { :uploads => { :token => params[:upload_id] } }).first
    if @metadata.upload.tree.status == 3
      flash[:warning] = "Your submission has already been finalized."
      redirect_to upload_path(:id => params[:upload_id])
    end
  end
  
  def update
    @metadata = Metadata.find(:all, :limit => 1, :joins => :upload, :conditions => { :uploads => { :token => params[:upload_id] } }, :readonly => false).first
    if @metadata.update_attributes(params[:metadata])
      @metadata.upload.tree.status = 3
      @metadata.upload.tree.save
      flash[:notice] = "Your submission has been finalized."
      redirect_to upload_path(:id => params[:upload_id])
    else
      render :action => 'edit', :upload_id => params[:upload_id]
    end
  end
end
