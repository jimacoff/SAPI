class Admin::UsersController < Admin::SimpleCrudController
  respond_to :js, :except => [:index, :destroy]

  load_and_authorize_resource :except => :index

  def new
    new! do
      load_associations
    end
  end

  def edit
    edit! do |format|
      load_associations
      format.js { render 'new' }
    end
  end

  protected
    def collection
      @users ||= end_of_association_chain.
        order(:name).page(params[:page])
    end
end

