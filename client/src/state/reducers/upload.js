import {  UPLOADEXCEL_REQUEST,UPLOADEXCEL_FAILURE,UPLOADEXCEL_SUCCESS,
                UPLOADEXCEL_INIT,LOGOUT_REQUEST} from '../../actions'
        const initialValues = {
        isEditable:false,
        isUpload:false,
        isSubmitting:false,
        errors:[],
        message:null,
        uploadError:false,
}

const uploadreducer =  (state= initialValues , actions) =>{
switch (actions.type) {
   
    
    case UPLOADEXCEL_INIT:
            return {...state,
                excelfile: null,
                params: actions.payload.params,
                auth: actions.payload.auth,
                nameToCode: null,
                errMessage:"",
                formatError:null,
                uploadErrorCheckMaster:false,
                normalEnd:false,
                loading : false,
                idx:null,
            }

    case UPLOADEXCEL_REQUEST:
            return {...state,
                excelfile: actions.payload.excelfile,
                params: actions.payload.params,
                auth: actions.payload.auth,
                nameToCode: actions.payload.nameToCode,
                errMessage:"",
                formatError:null,
                uploadErrorCheckMaster:false,
                normalEnd:false,
                loading : true,
                idx:null,
            }
    
    case UPLOADEXCEL_SUCCESS:
        return {...state,
                    params:{token:actions.params.token,
                            client:actions.params.client,
                            uid:actions.params.uid},
                            idx:actions.idx,
                            errHeader:null,
                            uploadError:false,
                            errMessage:"",
                            normalEnd:true,
            }                

    case UPLOADEXCEL_FAILURE:
        return {...state,
                errHeader:actions.errHeader,
                uploadError:true,
                formatError:actions.formatError,
                errMessage:actions.errMessage,
                uploadErrorCheckMaster:true,
                normalEnd:false
            }    

                      
    case  LOGOUT_REQUEST:
        return {}  
             
        
    default:
        return {...state,
            errHeader:"",
            uploadError:null,
            formatError:null,
            errMessage:"",
            uploadErrorCheckMaster:false,
            normalEnd:false
        }
    }
}

export default uploadreducer
