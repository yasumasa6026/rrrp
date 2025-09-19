//sigin_in(login) & sign_up

import {  SIGNUPFORM_REQUEST,SIGNUP_REQUEST,SIGNUP_SUCCESS,SIGNUP_FAILURE,
          LOGIN_REQUEST,LOGIN_SUCCESS,LOGIN_FAILURE,
          SCREEN_SUCCESS7,SECOND_SUCCESS7,SCREEN_CONFIRM7_SUCCESS,SECOND_CONFIRM7_SUCCESS,
          CHANGEPASSWORD_SUCCESS, CHANGEPASSWORD_FAILURE,
          FETCH_RESULT,SECONDFETCH_RESULT,
          MKSHPORDS_SUCCESS,CONFIRMALL_SUCCESS,SECOND_CONFIRMALL_SUCCESS,
          LOGOUT_REQUEST, LOGOUT_SUCCESS, } from '../../actions'

          
const initialValues = {
  isSubmitting:false,
  errors:[],
  error:{},
  isAuthenticated:false,
  isSignUp:false,
  email:"",
  token:null,
  client:null,
  uid:null,
  result:"",
}

export let getAuthState = state => state.auth
const authreducer =  (state= initialValues , actions) =>{
  switch (actions.type) {
      
    case SIGNUPFORM_REQUEST:
      return {
        isSignUp:true,
        isLogin:false,
        isChangePassword:false,
        isResetPassword:false,
        isDeleteUser:false,
      }

    
    case SIGNUP_REQUEST:
        return {
          isSubmitting:true,
          isSignUp:true,
          message: "signining in...",
          result: "",
        }
    

    // Successful?  Reset the signup state.
    case SIGNUP_SUCCESS:
      return {...state,
        isSubmitting:false,
        isSignUp:true,
        result: "ok"
      }

    // Append the error returned from our api
    // set the success and requesting flags to false
    case SIGNUP_FAILURE:
      return {
          time: new Date(),
          isSubmitting:false,
          isSignUp:true,
          result: actions.payload.message   /// payloadに統一
      }

    case CHANGEPASSWORD_SUCCESS:
      return {...state,
        isSubmitting:false,
        isSignUp:true,
        result: "ok"
      }

    case CHANGEPASSWORD_FAILURE:
      return {
          isSubmitting:false,
          isSignUp:true,
          error: actions.payload.error   /// payloadに統一
      }  


    // Set the requesting flag and append a message to be shown
    case LOGIN_REQUEST:
      return {
        isSubmitting:true,
        isAuthenticated:false,
        password:actions.payload.password,
        error:{},
      }

    // Successful?  Reset the login state.
    case LOGIN_SUCCESS:
      return {...state,
        message: "",
        isAuthenticated:true,
        "access-token":actions.payload["access-token"], 
        client:actions.payload.client, 
        uid:actions.payload.uid,
        expiry:actions.payload.expiry,
        "token-type":actions.payload["token-type"],
        authorization:actions.payload.authorization,
        isSubmitting:false,
      }

      
    case SCREEN_SUCCESS7:
    case SECOND_SUCCESS7:
    case SCREEN_CONFIRM7_SUCCESS:
    case SECOND_CONFIRM7_SUCCESS : 
    case FETCH_RESULT:
    case SECONDFETCH_RESULT:
    case MKSHPORDS_SUCCESS:
    case CONFIRMALL_SUCCESS:
    case SECOND_CONFIRMALL_SUCCESS:
      return {...state,
        "access-token":actions.payload.headers["access-token"]?actions.payload.headers["access-token"]:state["access-token"],
        client:actions.payload.headers.client, 
        uid:actions.payload.headers.uid,
        expiry:actions.payload.headers.expiry?actions.payload.headers.expiry:state.expiry,
        "token-type":actions.payload.headers["token-type"],
        authorization:actions.payload.headers.authorization,
      }
 
    // Append the error returned from our api
    // set the success and requesting flags to false
    case LOGIN_FAILURE:
      return {...state,
        isAuthenticated:false,
        isSubmitting:false,
        error:actions.payload.error,
    }

    case LOGOUT_REQUEST:
    return {
      "access-token":actions.payload["access-token"], 
      client:actions.payload.client, 
      uid:actions.payload.uid, 
      isAuthenticated:false,
      isSignUp:false,
      isLogin:true,
      isSubmitting:true,
      isChangePassword:false,
      isResetPassword:false,
      isDeleteUser:false,}

    case LOGOUT_SUCCESS:
      return {
        ...state,
        isSignUp:false,
        isLogin:true,
        isSubmitting:false,
        isChangePassword:false,
        isResetPassword:false,
        isDeleteUser:false,  
        isAuthenticated:false,
      }
 

    default:
      return state
  }
}

export default authreducer
