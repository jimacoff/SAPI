class Trade::ValidationErrorsController < TradeController
  respond_to :json

  def update
    @validation_error = Trade::ValidationError.find(params[:id])
    if @validation_error.update_attributes(validation_error_params)
      render json: @validation_error, status: :ok
    else
      render json: { 'errors' => @validation_error.errors },
        status: :unprocessable_entity
    end
  end

  private

  def validation_error_params
    params.require(:validation_error).permit(
      :is_ignored
    )
  end
end
