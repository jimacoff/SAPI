class Admin::QuotasController < Admin::SimpleCrudController
  before_filter :load_lib_objects, :only => [:new]

  def create
    create! do |success, failure|
      success.html {
        redirect_to admin_quotas_url,
        :notice => 'Operation successful'
      }
      failure.html {
        load_lib_objects
        render 'new'
      }
    end
  end

  protected

  def load_lib_objects
    @units = Unit.order(:code)
    @terms = Term.order(:code)
    @sources = Source.order(:code)
    @purposes = Purpose.order(:code)
    @geo_entities = GeoEntity.order(:name_en).joins(:geo_entity_type).
      where(:is_current => true,
            :geo_entity_types => {:name => GeoEntityType::SETS[GeoEntityType::DEFAULT_SET]})
  end

  def collection
    @quotas ||= end_of_association_chain.order('start_date DESC').
      page(params[:page]).search(params[:query])
  end
end
