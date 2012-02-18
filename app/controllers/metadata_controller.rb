class MetadataController < ApplicationController
  def edit
    @metadata = Metadata.find(:all, :limit => 1, :joins => :upload, :conditions => { :uploads => { :token => params[:upload_id] } })
  end
  
  def update
    @metadata = Metadata.find(:all, :limit => 1, :joins => :upload, :conditions => { :uploads => { :token => params[:upload_id] } })
    if @metadata.update_attributes(params[:book])
      redirect_to :action => 'edit', :upload_id => params[:upload_id]
    else
      render :action => 'edit', :upload_id => params[:upload_id]
    end
  end
end
