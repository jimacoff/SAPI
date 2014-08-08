class Admin::EventDocumentsController < Admin::SimpleCrudController
  defaults :resource_class => Document,
    :collection_name => 'documents', :instance_name => 'document'
  belongs_to :event

  def upload
  	@event = Event.find(params[:event_id]) #TODO can this be set by inherited resources?
    params[:files].each do |file|
      d = Document.create(event_id: @event.id, filename: file, title: 'test', date: Date.today, type: 'Document')
      puts d.errors.inspect
    end
    redirect_to admin_event_documents_url(@event)
  end

end
