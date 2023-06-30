# Be sure to restart your server when you modify this file.

# Avoid CORS issues when API is called from the frontend app.
# Handle Cross-Origin Resource Sharing (CORS) in order to accept cross-origin AJAX requests.

# Read more: https://github.com/cyu/rack-cors




Rails.application.config.middleware.insert_before 0, Rack::Cors do
    allow do
      origins '*'# this is not a good practice, it is not safe, there should be the url of dev and the one of prod
  
      resource '*',
        headers: :any,
        methods: [:get, :post, :put, :patch, :delete, :options, :head]
    end
  end