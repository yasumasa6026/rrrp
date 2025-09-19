import React from 'react'
import {connect} from 'react-redux'
import {LoginRequest} from '../actions'
import { useForm } from 'react-hook-form'
import  Menus7  from './menus7'
import  SignUp  from './signup'
import "../index.css"
//import  MyGanttChart  from './MyGanttChart'

const Login = ({isAuthenticated ,onSubmit,error,}) => {
  const { register, handleSubmit, formState: { errors }, } = useForm()
  // useForm({resolver: yupResolver(schema),
  if(isAuthenticated){
    document.title = "Menu"
    return(
       /*   <Menus/> */
          <Menus7 screenFlg = "first"/>

    )    
    }
  else{
  // if(isSignUp){
  //   document.title ="SginUp"
  //   return (
  //       <SignUp/>
  //   )}
  // else{
    document.title = "LogIn"
    return(
    <div>
    <h1>Login</h1>
    <form  onSubmit={handleSubmit(onSubmit)}>
      <p>
      <label htmlFor="email">
      email:
      </label>
      <input type="email"  placeholder="mail" {...register(
            "email",
            {            
            required: 'this is required',
            pattern: {
              value: /^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$/,
              message: 'Invalid email address',
            },
          })}/>
      {errors.email && errors.email.message}
      </p>
      <p>
      <label htmlFor="password">
      password:
      </label>
      <input type="password"  {...register("password",{ required: true })}  />
      </p>
      <button type="submit" >
      Submit
      </button>
        <div style={{ color: 'red' }}>
          {Object.keys(errors).length > 0 &&
            'There are errors, check your console.'}
            {error&&error.message}
        </div>
      <h1>概要</h1>
          <p>独学でruby,rails,react,postgresqlを学習し社内物流システムを作成してみた。</p>
          <p>ruby,rails,react,postgresqlについては素人なのでソースを参照するときは原本のマニュアルで妥当性、最適化を確認すること</p>
        <h2>・画面の説明（利用したreactの説明）</h2>
        <h2>・利用したrailsの説明</h2>
        <h2>・社内物流の概要</h2>
          <h3>・・子部品への展開と引当ルール</h3>
            <p>－－－＞画面とバッチで一括でで登録されたcustords,custschs,prdords,purordsは最下位の部品まで登録する。</p>
            <p>－－－＞prdords,purords作成プログラムmkprdpurordsで作成されたpprdords,purordsはでは子部品への展開はしない。
                      ここで作成されたprdords,purordsのremarkには"create by mkord"がsetされている。
              </p>
            <p>－－－＞mkprdordsは上位の部品からordsを作成する。この時購入単位・作業単位で数量を決定する。</p>
            <p>－－－＞子部品は上位の作業単位・購入単位に従ってその必要を決定する。ord作成時には作業単位・購入単位を考慮する。</p>
            <p>－－－＞mkprdpurordsでords作成時にfreeのordsを見つけた時はfreeに引当所要数を減する。</p>
        <h2>・導入方法</h2>
        <h2>・基本操作</h2>
          <h3>・・gridでのデータ追加・更新</h3>
            <p>－－－＞Enterで行ごとに追加・更新</p>
          <h3>・・grid内での SortBy</h3>
            <p>－－－＞ヘッダーの項目をCtrl+クリック</p>
          <h3>・・grid内での GroupBy</h3>
            <p>－－－＞ヘッダーの項目をAlt+クリック</p>
          <h2>rails</h2>
            <h3>activereord</h3>
              <p>model機能、crud機能は使用してない。</p>
              <p>postgresqlをActiveRecord::Base.connection.xxxxを利用してsqlをそのままコーディングしている。</p>
            <h3>activejob</h3>
        
      <h1 className="error">注意事項　あくまでも案であって利用に関しては各自十分に検証し自己責任で利用すること</h1>
    {/*}  <MyGanttChart/>*/}
    </form>
    
    </div>  
    )
  //  }
  }
}

const mapDispatchToProps = dispatch => ({
  onSubmit: ({email,password}) => dispatch(LoginRequest(email, password))
})

const mapStateToProps = state =>({
  isAuthenticated:state.auth.isAuthenticated ,
  isSubmitting:state.auth.isSubmitting ,
  error:state.auth.error ,
  isSignUp:state.auth.isSignUp ,
    token:state.auth.token ,
    client:state.auth.client,
    uid:state.auth.uid ,
  
})

export default connect(mapStateToProps,mapDispatchToProps)(Login)
