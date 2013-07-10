class SubjectsController < ApplicationController
  before_filter :authorize_admin
  layout 'admin'

  def index
    @subjects = Subject.paginate per_page: 25, page:  params[:page], order: :subject_code
  end

  def new
    @subject = Subject.new
  end

  def create
    Subject.create params[:subject]
    redirect_to subjects_path
  end

  def edit
    @subject = Subject.find params[:id]
  end

  def update
    subject = Subject.find params[:id]
    subject.update_attributes params[:subject]
    redirect_to subjects_path
  end

  def destroy
    Subject.find(params[:id]).destroy
    flash[:notice] = "Subject successfully deleted."
    redirect_to subjects_path
  end
end
