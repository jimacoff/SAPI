class TimelinesController < ApplicationController
  def index
    taxon_concept_ids = params[:taxon_concept_ids].split(',')
    res = taxon_concept_ids.map do |id|
      TimelinesForTaxonConcept.new(id).to_json
    end
    render :json => res
  end
end