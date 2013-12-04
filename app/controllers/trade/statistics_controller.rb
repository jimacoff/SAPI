class Trade::StatisticsController < ApplicationController
  layout 'admin'

  def index
  	@start_date = params[:stats_start_date] ? Date.parse(params[:stats_start_date]) : Date.today.beginning_of_year
  	@end_date = params[:stats_end_date] ? Date.parse(params[:stats_end_date]) : Date.today
    @years = (1975..Date.today.year).to_a.reverse
    @total_shipments = Trade::Shipment.count
    @last_updated = Trade::Shipment.maximum(:updated_at).strftime("%d/%m/%Y %H:%M")
    @shipments_uploaded = Trade::Shipment.where(:created_at => @start_date..@end_date).count
    @shipments_amended = Trade::Shipment.where(:updated_at => @start_date..@end_date).count
    @taxon_concepts_in_trade = Trade::Shipment.count(:taxon_concept_id, :distinct => true)
    @date_selected = params[:date] ? Date.parse("01/01/#{params[:date]['yearSelected']}") : Date.today
    @created_date_selected = params[:date] ? Date.parse("01/01/#{params[:date]['createdDateSelected']}") : Date.today
    @countries_reported_by_year = YearAnnualReportsByCountry.where(:year => @date_selected.year)
    @countries_reported_by_date_created = YearAnnualReportsByCountry.where(:created_at =>  @created_date_selected.strftime("01/01/%Y")..@created_date_selected.strftime("31/12/%Y"))
    @transactions = Statistics.get_total_transactions_per_year
  end
end
