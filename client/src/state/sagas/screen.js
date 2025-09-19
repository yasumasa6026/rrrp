import { call, put, select } from 'redux-saga/effects'
import axios         from 'axios'
import {SCREEN_SUCCESS7,SCREEN_FAILURE,SCREEN_CONFIRM7_SUCCESS, FETCH_RESULT, 
        SECOND_SUCCESS7,SECOND_FAILURE,SECOND_CONFIRM7_SUCCESS, 
        SECONDFETCH_RESULT,LOGIN_FAILURE,
        MKSHPORDS_SUCCESS,CONFIRMALL_SUCCESS,SECOND_CONFIRMALL_SUCCESS,
        //MKSHPACTS_RESULT,
        }
         from '../../actions'
import {getAuthState} from '../reducers/auth'
import history from '../../histrory'

function screenApi({params ,url,headers} ) {
    return axios({
        method: "POST",
        url: url,
        params:params,  //railsではscreen全ての情報を送れない。send lenggth max errorになる。(1024*・・・
        headers:headers,
        withCredentials: true
    })
  }

 // const delay = (ms) => new Promise(res => setTimeout(res, ms)) 
export function* ScreenSaga({ payload: {params}  }) {
  const auth = yield select(getAuthState) //
  let tmp 
  // let sagaCallTime = new Date()
  // let callTime =  sagaCallTime.getHours() + ":" + sagaCallTime.getMinutes() + ":" + 
  //             
  //url = 'http://localhost:3001/api/menus7'
  const url = `${process.env.REACT_APP_API_URL}/menus7`

  const headers = {'access-token':auth["access-token"],'client':auth.client,'uid':auth.uid ,
                    'expiry':auth.expiry,'token-type':auth["token-type"],
                    'authorization':auth.authorization,contentType: "application/json",}
    let message
    let hostError
    let lineData
    params = {...params,data:[],parse_linedata:{}} 
    // while (loading===true) {
    //   console.log("delay")
    //   yield delay(100)
    // }
    //params["fetch_data"] = ""  //net error 対策　1024*10 送信時は不要
    try{
      let response  = yield call(screenApi,{params ,url,headers} )
      // params.sortBy === [] だとrailsに取り込められない　paramsからsortByが
      switch (response.status) {
        case 200: 
          switch(response.data.params.buttonflg) {
            case 'viewtablereq7':
            case 'inlineedit7':   //第一画面又は第二画面のみ　両方修正は不可  更新画面要求
            case 'inlineadd7':  //追加画面要求
            case 'rejections':  //追加画面要求
              params = {...response.data.params,err:null,parse_linedata:{},index:0,clickIndex:[]}
              if(params.screenFlg==="second")
                  {return yield put({type:SECOND_SUCCESS7,payload:{data:response.data,params:{...params,index:-1},headers:response.headers } })}
              else
                  {return yield put({ type:SCREEN_SUCCESS7, payload:{data:response.data,params:{...params,index:-1},headers:response.headers}})}
            case "confirm7":  //データ更新時のEnteのbuttonflgはinlineedit7やinlineadd7ではなくてconfirm7になる。更新実行
              lineData  = response.data.params.parse_linedata
              params = {...params,screenFlg:response.data.params.screenFlg,
                          screenCode:response.data.params.screenCode,err:response.data.params.err,index:parseInt(params.index)}
              if(params.screenFlg==="second")
                {params = {...params,lineData:response.data.params.pareLineData,head:response.data.params.head}
                   yield put({type:SECOND_CONFIRM7_SUCCESS,payload:{lineData:lineData,index:parseInt(params.index),params:params,message:"",headers:response.headers} })
                }
              else
                {yield put({type:SCREEN_CONFIRM7_SUCCESS,payload:{lineData:lineData,index:parseInt(params.index),params:params,message:"",headers:response.headers} })}
              return   
            case "fetch_request":  //viewによる存在チェック内容表示
            case "check_request":   //項目毎のチェック帰りはfetchと同じ
                    lineData = response.data.params.parse_linedata
                     params = {...params,...response.data.params,screenFlg:response.data.params.screenFlg,
                                 screenCode:response.data.params.screenCode,err:response.data.params.err} 
                                 if(params.screenFlg==="second"){
                                     yield put({type: SECONDFETCH_RESULT, payload:{params:params,index:parseInt(params.index),lineData:lineData,headers:response.headers }}) 
                                 }else{
                                     // console.log(lineData)
                                     yield put({type: FETCH_RESULT, payload:{params:params,index:parseInt(params.index),lineData:lineData,headers:response.headers }}) 
                                 }  
                    return  
            case "delete":
                  data[parseInt(params.index)] = {...response.data.params.parse_linedata}
                  params = {...params,buttonflg:response.data.params.buttonflg,screenFlg:response.data.params.screenFlg,screenCode:response.data.params.screenCode}
                  if(params.screenFlg==="second")
                    {return yield put({type:SECOND_CONFIRM7_SUCCESS,payload:{data:data,params:params,message:"",headers:response.headers} })}
                  else
                    {return yield put({type:SCREEN_CONFIRM7_SUCCESS,payload:{data:data,params:params,message:"",headers:response.headers} })} 
            case "mkShpords":  //
              message = "out count : " + response.data.outcnt
              message = message + ",shortage count : " + response.data.shortcnt
              return yield put({ type: MKSHPORDS_SUCCESS, payload:{message:message,headers:response.headers}})       
           
              
           case "confirmAll":  //
           //case "adddetail":  //
              params = response.data.params
              if(params.err==""||params.err===null){
                message = "out count : " + response.data.outcnt
                message = message + ",out qty : " + response.data.outqty
                message = message + ",out amt : " + response.data.outamt
                return yield put({ type: CONFIRMALL_SUCCESS, payload:{message:message,headers:response.headers}})
              }
              else{
                  hostError = `error ${response.status}: Screen Something went wrong 。。。。${params.err} `
                  if(params.screenFlg==="second"){
                      return  yield put({type:SECOND_FAILURE,payload:{message:"",hostError:hostError,}})   
                  }else{  
                      return  yield put({type:SCREEN_FAILURE,payload:{message:"",hostError:hostError,}})   
                  }
              }
           case "MkPackingListNo":  //
               message = "out count : " + response.data.outcnt
               message = message + ",out qty : " + response.data.outqty
               return yield put({ type: CONFIRMALL_SUCCESS, payload:{message:message,headers:response.headers}})   

            case "MkCalendars":  //
                   message = response.data.params.message
                   return yield put({ type: CONFIRMALL_SUCCESS, payload:{message:message,headers:response.headers}})     
              
            case "MkInvoiceNo":
              message = "out count : " + response.data.outcnt
              message = message + ",out qty : " + response.data.outqty
              message = message + ",out amt : " + response.data.outamt 
              lineData  = response.data.params.parse_linedata
              params = {...params,screenFlg:response.data.params.screenFlg,
                          screenCode:response.data.params.screenCode,err:response.data.params.err,index:parseInt(params.index)}
              yield put({type:SCREEN_CONFIRM7_SUCCESS,payload:{lineData:lineData,index:parseInt(params.index),params:params,message:message,headers:response.headers} })
              
            case "confirmAllSecond":  //second画面専用
              message = "out count : " + response.data.outcnt
              return yield put({ type: SECOND_CONFIRMALL_SUCCESS, payload:{message:message,headers:response.headers}})     
            default:
                            }
            break       
       
        case 500: message = `error ${response.status}: Internal Server Error`
                  params = response.data.params
                  if(params.screenFlg==="second"){
                      return  yield put({type:SECOND_FAILURE,payload:{message:"",hostError: params.err,}})   //cannot display grid table
                    }else{  
                      return  yield put({type:SCREEN_FAILURE,payload:{message:"",hostError: params.err,}})   
                    }
        case 401: message = `error ${response.status}: Invalid credentials or Login TimeOut ${response.statusText}`
                  params = response.data.params
                  if(params.screenFlg==="second"){
                      return  yield put({type:SECOND_FAILURE,payload:{message:"",hostError:params.err,}})   
                    }else{  
                      return  yield put({type:SCREEN_FAILURE,payload:{message:"",hostError:params.err,}})   
                    }
                    break
        case 202:
              params = response.data.params
              if(params.screenFlg==="second"){
                  return  yield put({type:SECOND_FAILURE,payload:{message:"",hostError: params.err,}})   
              }else{  
                  return  yield put({type:SCREEN_FAILURE,payload:{message:"",hostError: params.err,}})   
              }
        default:
                  hostError = `error ${response.status}: Screen Something went wrong ${params.err} `
                    break      
      }
      if(params.screenFlg==="second"){
            return  yield put({type:SECOND_FAILURE,payload:{message:"",hostError:hostError,}})   
      }else{  
            return  yield put({type:SCREEN_FAILURE,payload:{message:"",hostError:hostError,}})   
      }
    }
    catch(e){
        switch (true) {
            case /code.*500/.test(e): hostError = `${e}: Internal Server Error `
                  return  yield put({type:SCREEN_FAILURE, payload:{message:"",hostError:hostError}})   
            case /code.*401/.test(e): message = ` Invalid credentials  Unauthorized or Login TimeOut ${e}`
                     console.log(`headers.access-token:${headers["access-token"]},headers.client:${headers.client},
                    header.expiry:${headers.expiry},headers.token-type:${headers["token-type"]},
                    headers.authorization:${headers.authorization},headers.contentType:${headers.contentType}`)
                    yield call(history.push,'/login')
                    return  yield put({type:LOGIN_FAILURE, payload:{message:message}})   
            default:
                hostError = `catch  Screen Something went wrong ${e} `
                      return  yield put({type:SCREEN_FAILURE, payload:{message:"",hostError:hostError}})   
      }
    }
  }
