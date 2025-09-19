export const LOGIN_REQUEST = 'LOGIN_REQUEST'
export const LOGIN_SUCCESS = 'LOGIN_SUCCESS'
export const LOGIN_FAILURE = 'LOGIN_FAILURE'

export const CHANGEPASSWORD_REQUEST = 'CHANGEPASSWORD_REQUEST'
export const CHANGEPASSWORD_SUCCESS = 'CHANGEPASSWORD_SUCCESS'
export const CHANGEPASSWORD_FAILURE = 'CHANGEPASSWORD_FAILURE'

export const LOGOUT_REQUEST = 'LOGOUT_REQUEST'
export const LOGOUT_SUCCESS = 'LOGOUT_SUCCESS'
export const SIGNUP_REQUEST = 'SIGNUP_REQUEST'
export const SIGNUPFORM_REQUEST = 'SIGNUPFORM_REQUEST'
export const SIGNUP_SUCCESS = 'SIGNUP_SUCCESS'
export const SIGNUP_FAILURE = 'SIGNUP_FAILURE'

export const MENU_REQUEST = 'MENU_REQUEST'
export const MENU_SUCCESS = 'MENU_SUCCESS'
export const MENU_FAILURE = 'MENU_FAILURE'

export const SCREENINIT_REQUEST = 'SCREENINIT_REQUEST'
export const SCREEN_REQUEST = 'SCREEN_REQUEST'
export const SCREEN_SUCCESS7 = 'SCREEN_SUCCESS7'
export const SCREEN_SUBFORM = 'SCREEN_SUBFORM'
export const SCREEN_CONFIRM7 = 'SCREEN_CONFIRM7'
export const SCREEN_CONFIRM7_SUCCESS = 'SCREEN_CONFIRM7_SUCCESS'
export const CONFIRMALL_SUCCESS = 'CONFIRMALL_SUCCESS'

export const SCREEN_FAILURE = 'SCREEN_FAILURE'

export const BUTTONLIST_REQUEST = 'BUTTONLIST_REQUEST'
export const BUTTONLIST_SUCCESS = 'BUTTONLIST_SUCCESS'
export const BUTTONLIST_FAILFURE = 'BUTTONLIST_FAILURE'

export const BUTTONFLG_REQUEST = 'BUTTONFLG_REQUEST'
export const BUTTON_RESET = 'BUTTON_RESET'

export const DOWNLOAD_REQUEST = 'DOWNLOAD_REQUEST'
export const DOWNLOAD_SUCCESS = 'DOWNLOAD_SUCCESS'
export const DOWNLOAD_FAILURE = 'DOWNLOAD_FAILURE'

export const FETCH_REQUEST = 'FETCH_REQUEST'
export const FETCH_RESULT = 'FETCH_RESULT'
export const FETCH_FAILURE = 'FETCH_FAILURE'

export const MKSHPORDS_SUCCESS = 'MKSHPORDS_SUCCESS'
export const MKSHPORDS_RESULT = 'MKSHPORDS_RESULT'
//export const MKSHPACTS_RESULT = 'MKSHPACTS_RESULT'

export const SECOND_REQUEST = 'SECOND_REQUEST'
export const SECOND_SUCCESS7 = 'SECOND_SUCCESS7'
export const SECOND_FAILURE = 'SECOND_FAILURE'
export const SECONDFETCH_REQUEST = 'SECONDFETCH_REQUEST'
export const SECONDFETCH_RESULT = 'SECONDFETCH_RESULT'
export const SECONDFETCH_FAILURE = 'SECONDFETCH_FAILURE'
export const SECOND_CONFIRM7 = 'SECOND_CONFIRM7'
export const SECOND_CONFIRMALL_REQUEST = 'SECOND_CONFIRMALL_REQUEST'
export const SECOND_CONFIRMALL_SUCCESS = 'SECOND_CONFIRMALL_SUCCESS'
export const SECOND_CONFIRM7_SUCCESS = 'SECOND_CONFIRM7_SUCCESS'
export const SECOND_SUBFORM = 'SECOND_SUBFORM'


export const UPLOADEXCEL_INIT = 'UPLOADEXCEL_INIT'
export const UPLOADEXCEL_REQUEST = 'UPLOADEXCEL_REQUEST'
export const UPLOADEXCEL_SUCCESS = 'UPLOADEXCEL_SUCCESS'
export const UPLOADEXCEL_FAILURE = 'UPLOADEXCEL_FAILURE'
export const INPUTFIELDPROTECT_REQUEST = 'INPUTFIELDPROTECT_REQUEST'
export const INPUTPROTECT_RESULT = 'INPUTPROTECT_RESULT'

export const YUP_REQUEST = 'YUP_REQUEST'
export const TBLFIELD_REQUEST = 'TBLFIELD_REQUEST'
export const TBLFIELD_SUCCESS = 'TBLFIELD_SUCCESS'
export const SECONDTBLFIELD_REQUEST = 'SECONDTBLFIELD_REQUEST'
export const SECONDTBLFIELD_SUCCESS = 'SECONDTBLFIELD_SUCCESS'
export const TBLFIELD_FAILURE = 'TBLFIELD_FAILFURE'
export const DROPDOWNVALUE_SET = 'DROPDOWNVALUE_SET'

export const GANTTCHART_REQUEST = 'GANTTCHART_REQUEST'
export const GANTTCHART_FAILURE = 'GANTTCHART_FAILURE'
export const GANTTCHART_SUCCESS = 'GANTTCHART_SUCCESS'

export const AREACHART_REQUEST = 'AREACHART_REQUEST'
export const AREACHART_FAILURE = 'AREACHART_FAILURE'
export const AREACHART_SUCCESS = 'AREACHART_SUCCESS'

export const UPDATENDITM_REQUEST = 'UPDATENDITM_REQUEST'
export const UPDATENDITM_SUCCESS = 'UPDATENDITM_SUCCESS'
export const UPDATENDITM_FAILURE = 'UPDATENDITM_FAILURE'
export const UPDATEALLOC_REQUEST = 'UPDATEALLOC_REQUEST'
export const UPDATEALLOC_SUCCESS = 'UPDATEALLOC_SUCCESS'
export const UPDATEALLOC_FAILURE = 'UPDATEALLOC_FAILURE'

export const SCREEN_DATASET = 'SCREEN_DATASET'
export const SECOND_DATASET = 'SECOND_DATASET'

export const RESET_REQUEST = 'RESET_REQUEST'

export const SignUpRequest =  (email, password,password_confirmation) => ({
  type:SIGNUP_REQUEST,
  payload: { email, password ,password_confirmation}
})

/*
export const SignupFormRequest =  () => ({
  type:SIGNUPFORM_REQUEST,
})
*/

export const LoginRequest  = (email, password) => ({
  type: LOGIN_REQUEST,
  payload: { email, password }
})

export const LogoutRequest =  (token,client,uid) => ({
  type: LOGOUT_REQUEST,
  payload: { token,client,uid }
})

export const LogoutSuccess = () => ({
  type: LOGOUT_SUCCESS,
 // payload: {token,client,uid }
})

/*
export const ChangePasswordFormRequest =  () => ({
  type: CHANGEPASSWORD_REQUEST,
  payload: {}
})
  */

export const ChangePasswordRequest =  (current_password,password,password_confirmation) => ({
  type: CHANGEPASSWORD_REQUEST,
  payload: { current_password,password,password_confirmation }
})

export const ChangePasswordSuccess = () => ({
  type: CHANGEPASSWORD_SUCCESS,
})

export const ChangePasswordFailure = () => ({
  type: CHANGEPASSWORD_FAILURE,
})


export const MenuRequest = (auth) => ({
  type:  MENU_REQUEST,
  payload: {auth}
})

export const MenuFailure = (errors) => ({
  type: MENU_FAILURE,
  errors: { errors }  //
})

//画面変更request
export const ScreenInitRequest = (params) => ({
  type:  SCREENINIT_REQUEST,
  payload: { params}  //AuthenticatorResponse
})

//画面内 check等のrequest
export const ScreenRequest = (params) => ({
  type:  SCREEN_REQUEST,
  payload: { params}  //
})


export const ScreenConfirm = (params,data) => ({
  type:  SCREEN_CONFIRM7,
  payload: { params,data}  //
})

export const ResetRequest = (params) => ({
  type:  RESET_REQUEST,
  payload: { params}  //
})

export const ScreenSubForm = (toggleSubForm,params) => ({
  type:  SCREEN_SUBFORM,
  payload: { toggleSubForm,params}  //
})

export const SecondSubForm = (toggleSubForm,params) => ({
  type:  SECOND_SUBFORM,
  payload: { toggleSubForm,params}  //
})


export const SecondRequest = (params) => ({
  type:  SECOND_REQUEST,
  payload: { params}  //
})


export const SecondConfirm = (params,data) => ({
  type:  SECOND_CONFIRM7,
  payload: { params,data}  //
})


export const SecondConfirmAllRequest = (params) => ({
  type:  SECOND_CONFIRMALL_REQUEST,
  payload: { params}  //
})


export const DropDownValueSet = (dropDownValue) => ({
  type:  DROPDOWNVALUE_SET,
  payload: {dropDownValue}  //
})

export const ScreenFailure = (message,hosterror) => ({
  type: SCREEN_FAILURE,
  payload: { message,hosterror }  //
})

export const DownloadRequest = (params,auth) => ({
  type: DOWNLOAD_REQUEST,
  payload: { params:params,auth:auth}
})

export const ButtonListRequest = (auth) => ({
  type:  BUTTONLIST_REQUEST,
  payload:{auth} 
})
export const ButtonListSuccess = (buttonListData) => ({
  type:  BUTTONLIST_SUCCESS,
  payload:{buttonListData} 
})
export const ButtonListFailure = (error) => ({
  type:  BUTTONLIST_FAILFURE,
  payload:{error} 
})

export const ButtonFlgRequest = (buttonflg,params) => ({
  type: BUTTONFLG_REQUEST,
  payload: { buttonflg,params}
})



export const ButtonReset = () => ({
  type:  BUTTON_RESET,
   //
})

export const FetchRequest = (params) => ({
  type: FETCH_REQUEST,
  payload: { params}
})

export const FetchResult = (params) => ({
  type: FETCH_RESULT,
  payload: { params}
})

export const FetchFailure = (params) => ({
  type: FETCH_FAILURE,
  payload: { params}
})
export const SecondFetchRequest = (params) => ({
  type: SECONDFETCH_REQUEST,
  payload: { params }
})

export const SecondFetchResult = (params) => ({
  type: SECONDFETCH_RESULT,
  payload: {params}
})

export const SecondFetchFailure = (params) => ({
  type: SECONDFETCH_FAILURE,
  payload: { params}
})

export const SecondFailure = (message,hostError) => ({
  type: SECOND_FAILURE,
  errors: { message,hostError }  //
})

export const MkShpordsResult = (data,params) => ({
  type: MKSHPORDS_RESULT,
  payload: { data,params}
})

export const InputFieldProtectRequest = () => ({
  type: INPUTFIELDPROTECT_REQUEST,
})
export const InputProtectResult = () => ({
  type: INPUTPROTECT_RESULT,
})

export const YupRequest = (params,auth) => ({
  type:  YUP_REQUEST,
  payload: { params,auth}  //
})

export const TblfieldRequest = (params,auth) => ({
  type:  TBLFIELD_REQUEST,
  payload: { params,auth}  //
})


export const TblfielSuccess = (messages) => ({
  type:  TBLFIELD_SUCCESS,
  payload: { messages}  //
})


export const SecondTblfieldRequest = (params,auth) => ({
  type:  SECONDTBLFIELD_REQUEST,
  payload: { params,auth}  //
})

export const SecondTblfielSuccess = (messages) => ({
  type:  SECONDTBLFIELD_SUCCESS,
  payload: { messages}  //
})


export const UploadExcelInit = (params,auth) => ({
  type: UPLOADEXCEL_INIT,  // 
  payload:{params,auth},
})

export const UploadExcelRequest = ({excelfile,nameToCode,params,auth}) => ({
  type: UPLOADEXCEL_REQUEST,  // 
  payload: {excelfile,nameToCode,params,auth}
})



export const UploadExcelSuccess = (payload) => ({
  type:UPLOADEXCEL_SUCCESS,  // 
  payload: {idx:payload.idx}
})


export const UploadExcelFailure = (payload) => ({
  type: UPLOADEXCEL_FAILURE,  // 
  payload: {uploadError:payload.uploadError}
})

export const ScreenDataSet = (data,params) => ({
  type: SCREEN_DATASET,  // 
  payload: {data:data,params:params}
})

export const SecondDataSet = (data,params) => ({
  type: SECOND_DATASET,  // 
  payload: {data:data,params:params}
})


export const GanttChartRequest = (params,auth) => ({
  type:  GANTTCHART_REQUEST,
  payload: { params,auth}  //
})

export const GanttChartSuccess = (params,auth) => ({
  type:  GANTTCHART_SUCCESS,
  payload: { params,auth}  //
})


export const GanttChartFailure = (params,auth) => ({
  type:  GANTTCHART_FAILURE,
  payload: { params,auth}  //
})


export const AreaChartRequest = (toggleAreaChart,params) => ({
  type:  AREACHART_REQUEST,
  payload: { toggleAreaChart,params}  //
})

export const AreaChartSuccess = (params,auth) => ({
  type:  AREACHART_SUCCESS,
  payload: { params,auth}  //
})


export const AreaChartFailure = (params,auth) => ({
  type:  AreaTCHART_FAILURE,
  payload: { params,auth}  //
})




export const UpdateNditmSuccess = (params,auth) => ({
  type:  UPDATENDITM_SUCCESS,
  payload: { params,auth}  //
})

// export const UpdateNditmREquest = (params,auth) => ({
//   type:  UPDATENDITM_REQUEST,
//   payload: { params}  //
// })

export const UpdateNditmFailure = (params,auth) => ({
  type:  UPDATENDITM_FAILURE,
  payload: { params,auth}  //
})

