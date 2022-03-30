class ApplicationController < ActionController::API
  private

  # allow the page size to be set via ?page_size=10 query param
  # but clamp it between 0 and 100 to ensure a reasonable result set
  def params_page_size
    (params[:page_size] || 10).clamp(0, 100)
  end
end
