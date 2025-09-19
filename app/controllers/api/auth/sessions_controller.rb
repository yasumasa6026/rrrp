##https://github.com/lynndylanhurley/devise_token_auth
###https://github.com/heartcombo/devise
module Api
  module Auth
    class SessionsController < DeviseTokenAuth::SessionsController
      before_action :authenticate_api_user!, except: [:create,:destroy]
       before_action :set_user_by_token, only: [:create]
      after_action :reset_session, only: [:destroy]
        # Prevent session parameter from being passed
        # Unpermitted parameter: session  
        def create
          super do
            create_and_assign_token
          end
        end
        def destroy
        end
    end    
  end
end
