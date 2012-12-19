class Admin::UnitsController < Admin::AdminController
  inherit_resources

  def index
    index! do |format|
      format.html { render :template => 'admin/trade_codes/index' }
    end
  end

  protected

  def collection
    @units ||= end_of_association_chain.order('code').page(params[:page])
  end
end