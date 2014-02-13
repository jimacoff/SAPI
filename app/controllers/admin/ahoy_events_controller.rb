class Admin::AhoyEventsController < Admin::SimpleCrudController
  authorize_resource :class => 'Ahoy::Event'
  respond_to :json

  def index
    @ahoy_events = Ahoy::Event.order('time DESC').page(params[:page])
  end
end