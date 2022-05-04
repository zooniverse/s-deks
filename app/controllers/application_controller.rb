class ApplicationController < ActionController::API
  rescue_from LabelExtractors::GalaxyZoo::UnknownTaskKey, LabelExtractors::Finder::UknownExtractor do |e|
    json_error_render(:unprocessable_entity, e)
  end

  private

  # allow the page size to be set via ?page_size=10 query param
  # but clamp it between 0 and 100 to ensure a reasonable result set
  def params_page_size
    (params[:page_size] || 10).to_i.clamp(0, 100)
  end

  def json_error_render(status, exception)
    render(
      status: status,
      json: { 'errors' => [{ 'type' => exception.class, 'detail' => exception.message }] }
    )
  end
end
