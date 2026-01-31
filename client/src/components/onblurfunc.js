//import moment from 'moment'
import { yupErrCheck } from './yuperrcheck'
import { yupschema } from '../yupschema'
//yupでできなかったこと
//検索項目では　xxxx_gridmessage = in は意味がない。　検索結果がセットされるため。
// 項目の順番が制限される。

export function  onBlurFunc7(screenCode,lineData,id){  //id:field
    let starttime
    let toduedate
    let strQty
    let gno
    //let autoAddFields = {}
    let itm_code_client
    lineData["confirm_gridmessage"] = "ok"
    //lineData["confirm"] = true
    switch( true ){
        case /itm_code$/.test(id)://ScreenLib.proc_add_empty_dataで対応
            if(/custschs|custords/.test(screenCode)){ //受注の時はopeitmのLT(duration)は使用できない。
                itm_code_client = id.split("_")[0] + "_itm_code_client"
                if(lineData[itm_code_client]===""){
                    lineData[itm_code_client] = lineData[id] 
                    //autoAddFields[itm_code_client] = lineData[itm_code_client]
                    }
                }
            break
        //starttime 将来部署別のカレンダーでrailsで求める。 prdord_commencementdate
        case /_isudate/.test(id):
            if(/pursch|purord|purinst/.test(id)){
                    starttime = id.split("_")[0] + "_starttime"
                    lineData[starttime] = lineData[id]
                    //autoAddFields[starttime] = lineData[id]
            }
            break
        case /_duedate/.test(id):
                //moment.defaultFormat = "YYYY-MM-DD HH:mm"
                // starttime = id.split("_")[0] + "_starttime" 
                // //if(lineData[starttime]===""||lineData[starttime]===undefined||lineData[starttime]===null){
                // if(lineData[starttime]===""){
                //         yymmdd = new Date(lineData[id]) 
                //     if(/cust/.test(screenCode)){ //受注の時はopeitmのLT(duration)は使用できない。
                //         yymmdd = new Date(yymmdd.setDate(yymmdd.getDate() - 1))
                //         lineData[starttime] = yymmdd.getFullYear()+"-"+(yymmdd.getMonth()+1)+"-"+yymmdd.getDate()+" "+yymmdd.getHours()+":"+yymmdd.getMinutes()
                //         autoAddFields[starttime] = lineData[starttime]
                //     }
                //     else{
                //         yymmdd = new Date(yymmdd.setDate(yymmdd.getDate() - parseFloat(lineData["opeitm_duration"])))
                //         lineData[starttime] = yymmdd.getFullYear()+"-"+(yymmdd.getMonth()+1)+"-"+yymmdd.getDate()+" "+yymmdd.getHours()+":"+yymmdd.getMinutes()
                //         autoAddFields[starttime] = lineData[starttime]
                //         if(lineData["prdord_commencementdate"]===""){
                //             lineData["prdord_commencementdate"] = lineData[starttime] 
                //             autoAddFields["prdord_commencementdate"] = lineData[starttime]                            
                //         }
                //     }       
                // }
                toduedate = id.split("_")[0] + "_toduedate" 
                if(lineData[toduedate]===""){
                        lineData[toduedate] = lineData[id] 
                        //autoAddFields[toduedate] = lineData[toduedate]
                }
            break
        case /_qty_case$/.test(id):  //opeitmsのレコードは既に求めていること。
            switch( true ){
                case /schs$/.test(screenCode):
                    strQty = id.split("_")[0] + "_qty_sch" 
                    break
                case /ords$|insts$|replyinputs$/.test(screenCode):
                    strQty = id.split("_")[0] + "_qty" 
                    break  
                case /acts$|dlvs$/.test(screenCode):
                    strQty = id.split("_")[0] + "_qty_stk" 
                    break 
            } 
            if (strQty !== undefined){
                if(Number(lineData["opeitm_packqty"])===0){  //opeitm_packqtyは購入時・作成後の完成時の単位
                    lineData[strQty] = lineData[id] 
                    }else{
                        lineData[strQty] =  String(lineData[id]*lineData["opeitm_packqty"])
                    }
                }
            break

        case /_invoiceno/.test(id):
            if(lineData[gno]!==""){
                gno = id.split("_")[0] + "_gno"
                //opeitm_packqtyは購入時・作成後の完成時の単位
                lineData[gno] = lineData[id] 
                //autoAddFields[gno] = lineData[gno]
            } 
            break
        case /^loca_code_cust$/.test(id):
            if(screenCode.match(/custord|custsch/)){
                if(lineData["loca_code_custrcvplc"]===""){
                    lineData["loca_code_custrcvplc"] = lineData[id]
                    //autoAddFields["loca_code_custrcvplc"] = lineData["loca_code_custrcvplc"]
                }
            }
            break
        case /^loca_code_shelfno$/.test(id):
                if(screenCode.match(/ords|acts|/)){
                    if(lineData["loca_code_shelfno"]==="dummy"){
                        lineData["loca_code_shelfno_gridmessage"]="err change dummy "
                    }else{lineData["loca_code_shelfno_gridmessage"]="ok"}
                }
                break
        case /^crr_code$/.test(id):
                if(screenCode.match(/puracts|custords/)){
                            if(lineData["crr_code"]==="dummy"){
                                lineData["crr_code_gridmessage"]="err change dummy "
                            }else{lineData["crr_code_gridmessage"]="ok"}
                }
                break
        case /endtime/.test(id):
                let strstarttime = id.replace("endtime","starttime")
                if(lineData[strstarttime]){
                            if(lineData[strstarttime]>lineData[id]){
                                   lineData[`${id}_gridmessage`]="err starttime > endtime "
                            }else{lineData[`${id}_gridmessage`]="ok"}
                        }
            //  break はなし　effectivestarttime|effectivestarttimeに続く　
        case /effectivestarttime|effectivestarttime/.test(id):
            if(lineData[id]){
                if(/^[0-2][0-9]:[0-2][0-9]$/.exec(lineData[id])){
                                                lineData[`${id}_gridmessage`]="ok"}else{lineData[`${id}_gridmessage`]="err HH:MM"}}
            break
        case /effectivetime/.test(id):
                if(lineData[id]){
                  lineData[id].split(",").map((item,idx)=>{
                    if(/^[0-2][0-9]:[0-2][0-9]~[0-2][0-9]:[0-2][0-9]$/.exec(item)&&
                       item.split("~")[0]<item.split("~")[1]){
                              lineData[`${id}_gridmessage`]="ok"}else{lineData[`${id}_gridmessage`]="err HH:MM"}})}
                break
        case /holidays/.test(id):
                if(lineData[id]){
                          lineData[id].split(",").map((item,idx)=>{
                            if(isValidMMDD(item)){
                                      lineData[`${id}_gridmessage`]="ok"}else{lineData[`${id}_gridmessage`]="err mmdd"}})}
                break
        case /dayofweek/.test(id):
          if(lineData[id]){
                    lineData[id].split(",").map((item,idx)=>{
                      if(/^[0-6]$/.exec(item)){
                                lineData[`${id}_gridmessage`]="ok"}else{lineData[`${id}_gridmessage`]="err 0-6:0:sun 1:mon 2:tue 3:wed 4:thu 5:fri 6:sat"}})}
                break
        case /mmdd/.test(id):
                if(lineData[id]){
                    if(isValidMMDD(lineData[id].replace(/\/|-/g,""))){
                                         lineData[`${id}_gridmessage`]="ok"}else{lineData[`${id}_gridmessage`]="err mmdd"}}
                break
        default:
             break    
        }
       
    return  lineData
}

function isValidMMDD(mmdd) {
  if (typeof mmdd !== 'string' || mmdd.length !== 4) {
    return false
  }

  const month = parseInt(mmdd.slice(0, 2), 10)
  const day = parseInt(mmdd.slice(2, 4), 10)

  if (isNaN(month) || isNaN(day)) {
    return false
  }

  if (month < 1 || month > 12 || day < 1 || day > 31) {
    return false
  }

  if (month === 2) {
    if (day > 29) {
      return false
    }
  } else if ([4, 6, 9, 11].includes(month)) {
    if (day > 30) {
      return false
    }
  }

  return true
}

export function   onFieldValite (lineData, field, screenCode) {  // yupでは　2019/12/32等がエラーにならない
    let Yup = require('yup')    
     let fieldSchema = (field, screenCode) => {
       let tmp = {}
       tmp[field] = yupschema[screenCode][field]
       return (
         Yup.object(
           tmp
         ))
     }
    
      let schema = fieldSchema(field, screenCode)
      lineData = yupErrCheck(schema,field,lineData)
    //lineData = yupErrCheck(yupschema[screenCode][field],field,lineData)
    return lineData
}


export function fetchCheck(lineData,id,fetch_check) {
    let fetchCheckFlg 
    let idKeys=[]
    //
    if(fetch_check.fetchCode[id]){
        let flg = true
        Object.keys(fetch_check.fetchCode).map((key,idx)=>{  //複数key対応
            if(fetch_check.fetchCode[id]===fetch_check.fetchCode[key]){
                if(lineData[key]===""||lineData[key]===undefined){
                    flg = false
                return  idKeys
                }
                else(idKeys.push({[key]:lineData[key]}))
            }
            return idKeys
        })
        if(flg){
        fetchCheckFlg = "fetch_request"
        }else{}//未入力keyがある。  
    }
    if(fetch_check.checkCode[id]){
            fetchCheckFlg = fetchCheckFlg === "fetch_request"?fetchCheckFlg+",check_request":"check_request"
            }
    return {fetchCheckFlg,idKeys}
}

