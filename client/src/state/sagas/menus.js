import { call, put} from 'redux-saga/effects'
import axios         from 'axios'

import { MENU_SUCCESS, MENU_FAILURE, } from '../../actions'
import history from '../../histrory'

function MenuGetApi({auth}) {
  //const url = 'http://localhost:3001/api/menus7'
  const url = `${process.env.REACT_APP_API_URL}/menus7`
  const headers =  { 'access-token':auth["access-token"], 
                    client:auth.client,
                    uid:auth.uid,
                    authorization:auth.authorization,
                    'Content-Type' : 'application/json'}
  const params =  {buttonflg:"menureq"}

  let getApi = (url, params,headers) => {
    return axios({
      method: "POST",
      url: url,
      params,headers,
      withCredentials: true
    })
  }
  return getApi(url, params,headers)
}

// MenuSaga({ payload: { token,client,uid} })  出し手と合わすこと
export function* MenuSaga({ payload: {auth} }) {
  try{
      let response   = yield call(MenuGetApi, ({auth} ) )
      yield put({ type: MENU_SUCCESS, action: response.data })
      yield call(history.push,'/menus7')}
  catch(e){
      let hostError 
      switch (true) {
        case /code.*500/.test(e): hostError = `${e}: Internal Server Error `
              return  yield put({type:MENU_FAILURE, payload:{hostError:hostError}})   
        case /code.*401/.test(e): hostError = ` Invalid credentials  Unauthorized or Login TimeOut ${e}`
                yield call(history.push,'/login')
                return  yield put({type:MENU_FAILURE, payload:{hostError:hostError}})   
        default:
          hostError = `Menu  Something went wrong ${e} `
          return  yield put({type:MENU_FAILURE, payload:{hostError:hostError}})   
        }
  }  
}      
