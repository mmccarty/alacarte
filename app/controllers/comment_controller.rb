

class CommentController < ApplicationController

  
  before_filter :authorize, :current_page, :only => [:destroy, :purge_comments]
  verify :method => :post, :only => [:create, :update],
         :redirect_to => :back
  verify :method => :delete, :only => [:destroy, :purge_comments],
         :redirect_to => :back

  def index
     begin 
      @mod = find_mod(params[:resource_id],"CommentResource")
      @comments = @mod.comments.find(:all, :order => "created_at DESC")
    rescue Exception => e
     logger.error("Exception in a comment: #{e}")
       render :status => 404,
      :text => (IO.read(File.join(RAILS_ROOT, 'public', '404.html'))) ,
      :layout => false 
    else
    render :action => :index, :layout => "help"
    end
  end

  def create 
    @mod = find_mod(params[:resource_id],"CommentResource")
    params[:comment][:author_name] = params[:comment][:author_name].empty? ? "Anonymous" : params[:comment][:author_name]

    if validate_recap(params,  @mod.errors)
      comment = Comment.new(params[:comment].merge(:comment_resource_id => @mod.id))
      unless comment.save
        flash[:author_email_error] = comment.errors[:author_email]
        flash[:body_error] = comment.errors[:body]
        flash[:author_email] = comment.author_email
        flash[:author_name] = comment.author_name
        flash[:body] = comment.body
      end
    else
      flash[:author_email] = params[:comment][:author_email]
      flash[:author_name] = params[:comment][:author_name]
      flash[:body] = params[:comment][:body]
    end

   

    redirect_to :back
  end

  def destroy
    comment = Comment.find(params[:id])
    comment.destroy

    redirect_to :back
  end

  def purge_comments
    @mod = find_mod(params[:resource_id],"CommentResource")
    @mod.comments.delete_all
    redirect_to :back
  end
end
