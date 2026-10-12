import { call, put } from 'redux-saga/effects'
import axios from 'axios'
import { persistor } from '../../state/store.js'

import history from '../../histrory'
import { MENU_FAILURE, LOGOUT_SUCCESS } from '../../actions'

function logoutApi (token, client, uid) {
  // const url = 'http://localhost:3001/api/auth/sign_out'
  const url = `${process.env.REACT_APP_API_URL}/auth/sign_out`
  const headers = { 'access-token': token, client: client, uid: uid }
  const params = { uid: uid }

  const getApi = (url, params, headers) => {
    return axios({
      method: 'DELETE',
      url: url,
      params: params,
      headers: headers
    })
  }
  return (getApi(url, params, headers)
    .then((response) => {
      return { response }
    })
    .catch(error => (
      { error }
    )))
}

export function * LogoutSaga ({ payload: { token, client, uid } }) {
  const { response, error } = yield call(logoutApi, token, client, uid)
  if (response || !error) {
    yield put({ type: LOGOUT_SUCCESS })
    // persistor.purge() これを実行すると、Storageに保存された情報がクリアされる
  } else {
    persistor.purge() // これを実行すると、Storageに保存された情報がクリアされる
    let message
    switch (error.status) {
      case 500: message = 'Menu Internal Server Error'
        break
      case 401: message = 'Menu Invalid credentials'
        break
      case 404: message = 'User was not found or was not logged in.'
        break
      default: message = error
    }
    yield put({ type: MENU_FAILURE, payload: { hostError: message } })
  }
}
//  送信されてない。
