##https://github.com/lynndylanhurley/devise_token_auth
module Api
  module Auth
    # class RegistrationsController < DeviseTokenAuth::RegistrationsController
    #   ###before_action :authenticate_api_user!, except: [:create,:new]
    #   ###def new  ### createを使用する。
    #   ###end  
    #   private
    #   def sign_up_params
    #       params.permit(*params_for_resource(:sign_up))
    #   end
    # end  class Users::RegistrationsController < Devise::RegistrationsController
    class Users::RegistrationsController < DeviseTokenAuth::RegistrationsController
      before_action :authenticate_api_user!, except: [:create]
      def create
        # 画面から送信されたメールアドレスを取得
        email = params[:email]  ##personsに登録されとぃるmailのみ登録対象
        strsql = "SELECT 1 FROM persons p WHERE p.email = '#{email}' and expiredate > now()"
        # SQLクエリを実行して、メールアドレスが存在するか
        # Pemailsテーブルにメールアドレスが存在するかチェック
        if ActiveRecord::Base.connection.select_value(strsql)
          # メールアドレスが存在する場合、通常のcreate処理を続行
          super
          return
        else
          # メールアドレスが存在しない場合、404を返す
          render json: { error: 'Email not found in persons table' }, status: :not_found
        end
      end
    end
  end
end

###
# system@rrrp.comは規定値として登録されています。
# personsにmailを登録しその後signupしてください。
# 　登録されたmailにconfirm　mailが届くのでそこでconfirmしてください。
# 　開発環境ではMailCatcherを利用しました。
###
# MailCatcher
# https://qiita.com/uenomoto/items/1af0626e18bde4c2e245  から引用
###

# MailCatcherのgemを使って、送信メールをブラウザで確認します。

# まずはインストールから
# gem install mailcatcher
# このGemはbundle installでインストールすると正常に動作しないことがあるらしいです。
# このGemの開発者もgem install mailcatcherでインストールすることをすすめています

# 次に、Railsの設定を変更します。開発環境の設定
# config/environments/development.rbを以下のように設定します
# 大体41行あたりです

# # Don't care if the mailer can't send.
# config.action_mailer.raise_delivery_errors = false
# # ここから追加
# config.action_mailer.delivery_method = :smtp
# config.action_mailer.smtp_settings = { address: "localhost", port: 1025 }

# これで、Railsアプリケーションから送信されるメールはMailCatcherによってキャッチされ、
# http://localhost:1080 で閲覧可能になります。