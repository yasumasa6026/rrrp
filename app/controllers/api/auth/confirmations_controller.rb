##https://github.com/lynndylanhurley/devise_token_auth
module Api
  module Auth
    class ConfirmationsController < ::DeviseTokenAuth::ConfirmationsController
      before_action :authenticate_api_user!, except: [:show]# メール内のリンクがクリックされた時の処理
      def show
        super do |resource|
          # 成功時の追加ロジック（例: カスタムログ、別モデルの更新など）
        end
      end
      private
      def after_confirmation_path_for(resource_name, resource)
        # デフォルトではフロントエンドの config.default_url_options にリダイレクトされます
        # 必要に応じて特定のURLを返すようオーバーライドします
        "#{super}?account_confirmed=true"
      end
    end  
  end
end
