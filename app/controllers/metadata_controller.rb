require 'resque_scheduler'

class MetadataController < ApplicationController
  def show
    @metadata = Metadata.find(:all, :limit => 1, :joins => :upload, :conditions => { :uploads => { :token => params[:upload_id] } }).first
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
      Resque.remove_delayed(Tree, @metadata.upload.tree.id)
      flash[:notice] = "Thank you, #{help.sanitize(@metadata.contact_givenname)}. Your submission has been finalized."
      redirect_to upload_path(:id => params[:upload_id])
    else
      render :action => 'edit', :upload_id => params[:upload_id]
    end
  end
end
