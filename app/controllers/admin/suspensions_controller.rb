class Admin::SuspensionsController < Admin::SimpleCrudController
  before_filter :load_lib_objects

  def update
    update! do |success, failure|
      success.html {
        redirect_to admin_suspensions_url,
        :notice => 'Operation successful'
      }
      failure.html {
        load_lib_objects
        render 'new'
      }

      success.js { render 'create' }
      failure.js {
        load_lib_objects
        render 'new'
      }
    end
  end

  def create
    create! do |success, failure|
      success.html {
        redirect_to admin_suspensions_url,
        :notice => 'Operation successful'
      }
      failure.html { render 'create' }
    end
  end

  protected

  def load_lib_objects
    @current_suspensions = Suspension.
      where(:is_current => true).
      where(:taxon_concept_id => nil)
    @units = Unit.order(:code)
    @terms = Term.order(:code)
    @sources = Source.order(:code)
    @purposes = Purpose.order(:code)
    @geo_entities = GeoEntity.order(:name_en).joins(:geo_entity_type).
      where(:is_current => true, :geo_entity_types => {:name => 'COUNTRY'})
  end

  def collection
    @suspensions ||= end_of_association_chain.order('start_date').
      page(params[:page])
  end
end
