Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # https://lipanski.com/posts/activestorage-cdn-rails-direct-route
  # add a direct public URL path helper for serving public assets
  # via a hosted DNS / CDN instead of via the blob service storage URL
  # e.g. Rails.application.routes.url_helpers.rails_public_blob_url(TrainingDataExport.first.file)
  # linked to private / public storage services
  #
  # direct :rails_public_blob do |blob|
  #   File.join(ENV['CDN_HOST'], blob.key)
  # end

  # Defines the root path route ("/")
  root 'home#index'

  resource :user_reductions, only: [:create]

  resource :training_data_exports, only: [:create]

  # all other routes go here
end
