//api_user_session POST /api/auth/sign_in(.:format) api/auth/sessions#create
import { call, put } from 'redux-saga/effects'
import axios         from 'axios'
import {LOGIN_FAILURE,
        //MENU_REQUEST,
        LOGIN_SUCCESS,MenuRequest,
        ButtonListRequest
                  } from '../../actions'

function loginApi({ email, password}) {
  //const url = 'http://localhost:3001/api/auth/sign_in'
  //axios.defaults.headers.post['Content-Type'] = 'application/json'
  //axios.defaults.headers.post[ 'Access-Control-Allow-Origin'] = process.env.REACT_APP_RAILS_URL
  const url = `${process.env.REACT_APP_API_URL}/auth/sign_in`
  const params =  {'email':email, 'password':password }
  const headers = { 'Content-Type':'application/json',}
 
  let getApi = (url, params,headers) => {
    return axios({
        method: "POST",
        url: url,
        params: params,
        headers: headers,
        withCredentials: true
      })
  }
  return getApi(url, params,headers)
}

export function* LoginSaga({ payload: { email, password } }) {
  try{
      let results = yield call(loginApi, { email, password} ) 
      console.log(`headers.access-token:${results.headers["access-token"]},headers.client:${results.headers.client},
                    header.expiry:${results.headers.expiry},headers.token-type:${results.headers["token-type"]},
                    headers.authorization:${results.headers.authorization},headers.contentType:${results.headers.contentType}`)
        yield put({ type: LOGIN_SUCCESS, payload: results.headers })
        yield put(MenuRequest(results.headers) )      
        yield put(ButtonListRequest(results.headers) )
    }
    catch(error){ 
             return  yield put({type:LOGIN_FAILURE,payload:{error:error,}})     
        }
}