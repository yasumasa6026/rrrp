// api_user_session POST /api/auth/sign_in(.:format) api/auth/sessions#create
import { call, put } from 'redux-saga/effects'
import axios from 'axios'
import {
  LOGIN_FAILURE,
  // MENU_REQUEST,
  LOGIN_SUCCESS, MenuRequest,
  ButtonListRequest
} from '../../actions'

function loginApi ({ data }) {
  // const url = 'http://localhost:3001/api/auth/sign_in'
  // axios.defaults.headers.post['Content-Type'] = 'application/json'
  // axios.defaults.headers.post[ 'Access-Control-Allow-Origin'] = process.env.REACT_APP_RAILS_URL
  const url = `${process.env.REACT_APP_API_URL}/auth/sign_in`
  const params = { email: data.email, password: data.password }
  const headers = { 'Content-Type': 'application/json' }

  const getApi = (url, params, headers) => {
    return axios({
      method: 'POST',
      url: url,
      params: params,
      headers: headers,
      withCredentials: true
    })
  }
  return getApi(url, params, headers)
}

export function * LoginSaga ({ payload: { data } }) {
  try {
    const results = yield call(loginApi, { data })
    // console.log(`headers.access-token:${results.headers["access-token"]},headers.client:${results.headers.client},
    //               header.expiry:${results.headers.expiry},headers.token-type:${results.headers["token-type"]},
    //               headers.authorization:${results.headers.authorization},headers.contentType:${results.headers.contentType}`)
    yield put({ type: LOGIN_SUCCESS, payload: results })
    const headers = { ...results.headers, token: results.headers['access-token'] }
    yield put(MenuRequest(headers))
    yield put(ButtonListRequest(headers))
  } catch (error) {
    return yield put({ type: LOGIN_FAILURE, payload: { error: error } })
  }
}
