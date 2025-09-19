# Be sure to restart your server when you modify this file.

# Avoid CORS issues when API is called from the frontend app.
# Handle Cross-Origin Resource Sharing (CORS) in order to accept cross-origin Ajax requests.

# Read more: https://github.com/cyu/rack-cors

Rails.application.config.middleware.insert_before 0, Rack::Cors do
   allow do
     # origins "*"
     origins 'localhost:3001','localhost:3000'
#
#     resource "*",
#       headers: :any,
#       methods: [:get, :post, :put, :patch, :delete, :options, :head]
#   end  allow do
      # resource '/api/*',
      # origins 'localhost:3000', '127.0.0.1:3000',
      # origins 'yasumasa:3000','127.0.0.1:3000', ## 追加  小文字 
      #/\Ahttp:\/\/192\.168\.1\.\d{1,3}(:\d+)?\z/,
      # /\Ahttp:\/\/192\.168\.10\.\d{1,3}(:\d+)?\z/
      # regular expressions can be used here
 
      resource '/api/*',
        headers:  :any, ## 追加
        methods: [:get, :post, :put, :patch, :delete, :options, :head],
        expose: ['access-token', 'client', 'uid', 'expiry', 'token-type', 'authorization'], 
        # Expose devise_token_auth headers
        credentials: true # Allow cookies or credentials if needed
    end
end
