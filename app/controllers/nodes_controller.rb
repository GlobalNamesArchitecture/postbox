class NodesController < ApplicationController
  def index
    respond_to do |format|

      raise "Child node cannot be rendered" unless (params[:parent_id].to_i > 0 or !params[:parent_id])

      tree = Tree.find(params[:tree_id]) rescue nil
      parent_id = params[:parent_id] ? params[:parent_id] : tree.root
      @nodes = tree.children_of(parent_id)

      format.html do
        response.headers['Content-type'] = 'text/html; charset=utf-8'
        render :layout => false
      end

    end
  end
end
