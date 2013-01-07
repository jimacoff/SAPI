class Admin::ChangeTypesController < Admin::SimpleCrudController
  inherit_resources

  def index
    @designations = Designation.order(:name)
    index!
  end

  def create
    @designations = Designation.order(:name)
    super
  end

  protected
    def collection
      @change_types ||= end_of_association_chain.includes(:designation).
        order('designation_id, name').
        page(params[:page])
    end
end
