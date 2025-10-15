//excelからの項目とscreenfieldsの項目のtype チェックが必要。未実施。
//規定値はセットされない。
import {yupschema} from '../yupschema'
import {dataCheck7} from './yuperrcheck'
import {onBlurFunc7} from './onblurfunc'
export  function yupErrCheckBatch(lines,screenCode) 
{
    let Yup = require('yup')
    let screenSchema = Yup.object().shape(yupschema[screenCode])
    let uploadexcel = []
    let uploadErrorCheckMaster = false
    let tblnamechop = screenCode.split("_")[1].slice(0, -1)
    let batchField = ""
    //let autoAddFields = {}
    lines.map((line,inx) => {
        if(["add","update","delete"].includes(line["aud"])){
            try{
                line[`confirm`] = true  //rb uploadで confirm=trueのみを対象としているため
                let row = {}
                Object.keys(line).map((fd)=>{
                     if(screenSchema.fields[fd]){  //対象は入力項目のみ
                        batchField = fd
                        row ={...row,[fd]:line[fd]}
                        }
                        return row
                     }
                )
                screenSchema.validateSync(row)
                line[`${tblnamechop}_confirm_gridmessage`] = ""
                Object.keys(screenSchema.fields).map((fd)=>{  // line:_gridmessageを含まない
                    batchField = fd
                    row = dataCheck7(screenSchema,fd,row) //row:_gridmessageを含む
                    if(row[`${fd}_gridmessage`] !== "ok"){
                          row[`${tblnamechop}_confirm_gridmessage`] = `error x ${fd} field:${fd} ` + row[`${fd}_gridmessage`]
                          uploadErrorCheckMaster = true
                          row[`confirm`] = false
                          row = {...row,[fd]:row[fd]}
                        }else{
                            row = onBlurFunc7(screenCode,row,fd)
                        }
                        return {...line,row}
                    }
                )
            }      
            catch(err){  //jsonにはxxxx_gridmessageはない。
                line[`${tblnamechop}_confirm_gridmessage`] = `error y ${err} field:${batchField} ` + line[`${tblnamechop}_confirm_gridmessage`]
                line[`confirm`] = false
                uploadErrorCheckMaster = true
            }
        }else{
            if(line["aud"]==="aud"){
                }else{
                    line[`${tblnamechop}_confirm_gridmessage`] = "error z missing aud--> add OR update OR delete "
                    line[`confirm`] = false
                    uploadErrorCheckMaster = true
            }   
        }  
        uploadexcel.push(line) 
        return {uploadexcel,uploadErrorCheckMaster}
    })
    return {uploadexcel,uploadErrorCheckMaster}
}  




  