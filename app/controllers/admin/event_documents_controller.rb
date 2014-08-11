class Admin::EventDocumentsController < Admin::SimpleCrudController
  authorize_resource :class => 'Document'
  defaults :resource_class => Document,
    :collection_name => 'documents', :instance_name => 'document'
  belongs_to :event
  respond_to :js, :only => [:edit]

  def edit
    edit! do |format|
      load_associations
      format.js { render 'new' }
    end
  end

  def destroy
    destroy! do |success, failure|
      success.html { redirect_to admin_event_documents_url(@event), :notice => 'Operation succeeded' }
      failure.html {
        redirect_to admin_event_documents_url(@event),
          :alert => if resource.errors.present?
              "Operation #{resource.errors.messages[:base].join(", ")}"
            else
              "Operation failed"
            end
      }
    end
  end

  def upload
  	@event = Event.find(params[:event_id]) #TODO can this be set by inherited resources?
    params[:files].each do |file|
      d = Document.create(
        event_id: @event.id,
        language_id: params[:language_id],
        filename: file, date: params[:date], type: 'Document')
      puts d.errors.inspect
    end
    redirect_to admin_event_documents_url(@event)
  end

  protected

  def collection
    @documents ||= end_of_association_chain.includes(:language).
      order(:title).
      page(params[:page])
  end

  def load_associations
    @languages = Language.select([:id, :name_en, :name_es, :name_fr]).order(:name_en)
    @english = Language.find_by_iso_code1('EN')
  end

end
