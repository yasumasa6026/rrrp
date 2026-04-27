//new_api_user_registration GET /api/auth/sign_up(.:format)   api/auth/registrations#new
import { call, put, select } from 'redux-saga/effects'
import axios         from 'axios'
import {PDF_SUCCESS,PDF_FAILURE} from '../../actions'
import {saveAs} from "file-saver"

function pdfApi({params,auth}) {
  let token = auth.token       
  let client = auth.client         
  let uid = auth.uid 
  const url = `${process.env.REACT_APP_API_URL}/pdf`
  const headers =  { 'access-token':auth["access-token"], 
                    client:auth.client,
                    uid:auth.uid,
                    authorization:auth.authorization,
                    'Content-Type' : 'application/pdf'}
  const options ={method:'POST',
    params: params,
    headers:headers,
    url,}
    return (axios(options))
}

export function * PdfSaga({payload:{params,auth}}) {
  let response = yield call(pdfApi, {params,auth})
  let message
    switch (response.status) {
      case 200:  
          yield put({ type: PDF_SUCCESS, payload:{params:params}})   
          let dayoptions = { year: 'numeric', month: 'long', day: 'numeric' ,hour:'numeric',minute:'numeric',second:'numeric'}
          let wtime = (new Date()).toLocaleDateString('ja-JA', dayoptions).replace(/:/g,"-")
          const blob = new Blob([response.data], {type: "pdf"})
          const fileExtension = '.pdf'
          let fileName = params.listNamePdf + "_" + wtime 
          saveAs(blob, fileName + fileExtension)
          break
      case 500:
             message = 'Internal Server Error'
             yield put({ type: PDF_FAILURE, payload:{hostError: message} })
             break
      case 401:
              message = 'Invalid credentials or Login TimeOut'
              yield put({ type: PDF_FAILURE, payload:{hostError: message} })
              break
      default:
             message = `${response.status} :downLoad Something went wrong ${response.statusText}`}
             yield put({ type: PDF_FAILURE, payload:{hostError: message} })
   }
