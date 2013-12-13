class Api::V1::PurposesController < ApplicationController
  caches_action :index, :cache_path => Proc.new { |c| c.params }
  def index
    @purposes = Purpose.all(:order => "code")
    render :json => @purposes,
      :each_serializer => Species::PurposeSerializer,
      :meta => {:total => @purposes.count}
  end
end
