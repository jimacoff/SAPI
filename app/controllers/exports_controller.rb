class ExportsController < ApplicationController
  # GET exports/
  #
  def index
    @designations = Designation.order('name')
    @cites = @designations.find_by_name(Designation::CITES)
    @eu = @designations.find_by_name(Designation::EU)
    @species_listings = SpeciesListing.order('name')
  end

  def download
    case params[:data_type]
      when 'Quotas'
        result = Quota.export params[:filters]
      when 'Suspensions'
        result = Suspension.export
    end
    if result.is_a?(Array)
      send_file result[0], result[1]
    else
      redirect_to exports_path, :notice => "There are no #{params[:data_type]} to download."
    end
  end
end
