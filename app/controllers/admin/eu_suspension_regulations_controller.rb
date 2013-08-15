class Admin::EuSuspensionRegulationsController < Admin::EventsController
  #this needs to be specified, because otherwise defaults to 'event'
  defaults :resource_class => EuSuspensionRegulation,
    :collection_name => 'eu_suspension_regulations', :instance_name => 'eu_suspension_regulation'

  def activate
    @eu_suspension_regulation = EuSuspensionRegulation.find(params[:id])
    @eu_suspension_regulation.activate!
    render 'create'
  end

  protected
    def collection
      @eu_suspension_regulations ||= end_of_association_chain.
        order(:designation_id, :name).includes(:designation).page(params[:page])
    end

    def load_associations
      @eu_suspension_regulations_for_dropdown = EuSuspensionRegulation.order(:effective_at)
    end

end