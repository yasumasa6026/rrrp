import { call, put, select } from 'redux-saga/effects'
import axios         from 'axios'
import { GANTTCHART_SUCCESS,SCREEN_FAILURE,SECOND_SUCCESS7,}     from '../../actions'
//import { ReactReduxContext } from 'react-redux';
import {getAuthState} from '../reducers/auth'


function GanttApi({params,headers}) {
  //const url = 'http://localhost:3001/api/ganttcharts'
  const url = `${process.env.REACT_APP_API_URL}/ganttcharts`


return axios({
        method: "POST",
        url: url,
        params:params,  //railsではscreen全ての情報を送れない。send lenggth max errorになる。(1024*・・・
        headers:headers,
        withCredentials: true
    })
.then((response ) => {
return  {response}  
})
.catch(error => (
{ error }
))
}

export function* GanttChartSaga({ payload: {params}  }) {
    const auth = yield select(getAuthState) //
    const headers = {'access-token':auth["access-token"],'client':auth.client,'uid':auth.uid ,
                    'expiry':auth.expiry,'token-type':auth["token-type"],
                    'authorization':auth.authorization,contentType: "application/json",}
    let {response,error} = yield call(GanttApi,{params ,headers} )
    if(response || !error){
        switch (params.buttonflg){  //buttonflg req　時の内容
            case "ganttchart":
            case "reversechart":
                let tasks = []
                tasks = response.data.tasks.map((task,idx)=>
                                 tasks[idx] = {...task,start:new Date(task.start),end:new Date(task.end),}
                                 )
                return yield put({ type: GANTTCHART_SUCCESS, payload:{ tasks:tasks,viewMode:params.viewMode,
                                                                                screenCode:params.screenCode,
                                                                                buttonflg:params.buttonflg,
                                                                                screenFlg:params.screenFlg,}} )  
            case "updateNditm":  //ganttchartからtaskをclickされた時
            case "updateTrngantt":
                params = {...response.data.params,err:null,parse_linedata:{},index:0,clickIndex:[]}
                return yield put({type:SECOND_SUCCESS7,payload:{data:response.data,params:params} })
        }}else
        {  
        let message
        switch (true) {
          case /code.*500/.test(error): message = 'Internal Server Error'
           break
          case /code.*401/.test(error): message = 'Invalid credentials or Login TimeOut'
           break
          default: message = `Something went wrong ${error}`}
        yield put({type:SCREEN_FAILURE, payload:{message:"",hostError:message}})
        }
 }      