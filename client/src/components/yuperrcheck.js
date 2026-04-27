export  function yupErrCheck (schema,field,lineData) {
  let mfield 
  try{
      if(field==="confirm"){schema.validateSync(lineData)
            lineData["confirm_gridmessage"] = "doing"
            let dclinedata = {}
            Object.keys(lineData).map((fd)=>{
                mfield = fd+"_gridmessage"
                if(fd!=="confirm_gridmessage"){
                    dclinedata = dataCheck7(schema,fd,{[fd]:lineData[fd]})
                    lineData["confirm_gridmessage"] = (lineData["confirm_gridmessage"] === "doing" ? dclinedata[mfield]:
                            lineData["confirm_gridmessage"] === "ok" ?  dclinedata[mfield] : lineData["confirm_gridmessage"] + dclinedata[mfield]) 
                    lineData[mfield] = dclinedata[mfield]
                }
             })
      }
      else{schema.validateSync({[field]:lineData[field]})
            if(lineData.confirm_gridmessage === "ok"){
                       dataCheck7(schema,field,lineData) 
                }
         }  
      // if(lineData.confirm_gridmessage === "doing"){
      //                 Object.keys(lineData).map((fd)=>{
      //                  dataCheck7(schema,fd,{[fd]:lineData[fd]})             }
      //                 ) 
      //       }    
      return lineData
   }      
    catch(err){
        lineData.confirm = false
        lineData["confirm_gridmessage"] = " error yupErrCheck"
        lineData["errPath"] = []
        err.errors.map((fd) => {
            mfield = fd.split(" ")[0]+"_gridmessage"  //ex:fd:purord_confirm must be a `string` type, but the final value was:..."
            lineData[mfield] = " error "+ fd
            lineData["errPath"].push(mfield)
        })  
    return lineData
    }
} 

//未実施　yupでは数値項目で　"スペース999" がエラーにならない。

// yupでは　2019/12/32等がエラーにならない。　2020/01/01になってしまう
export function dataCheck7(schema,field,lineData){ 
    let  mfield = field+"_gridmessage"
    let yyyymmdd = []
    if(schema.fields[field]){
      lineData[mfield] = "ok"
      if(schema.fields[field]["_type"]==="date"){
          let nval
          let typeCheck = typeof(lineData[field])
          if(typeCheck==="string"){
              yyyymmdd =  lineData[field].split(/\/|-|\s|T|:|\./)
              yyyymmdd = [0,1,2,3,4,5].map((val,idx)=>{  //[3,4,5] 時間:分:秒
              nval =  (yyyymmdd[idx]   === undefined ? 0 : Number(yyyymmdd[idx] ) )
                switch(idx){
                  case 0:  ///yyyy
                      lineData[field]=String(nval)+"-"
                      lineData[mfield] = "ok"
                      lineData[mfield] =  (isNaN(nval) ? "1 error yyyy:20xx":nval>2099||nval< 2000 ? "2 error yyyy:20xx" : lineData[mfield] )
                    break
                  case 1:  ///mm
                      lineData[field]= lineData[field]+String(nval)+"-"
                      lineData[mfield] = (isNaN(nval) ?  " error MM:1-12":nval>12||nval<1 ? " error MM:1-12":lineData[mfield])
                      break
                  case 2:   ///Day
                      let daysInMonth = [31, isLeapYear(Number(yyyymmdd[0])) ? 29 : 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
                      lineData[field]=lineData[field]+String(nval)+" "
                      lineData[mfield] = (isNaN(nval) ? " error DD:1-31":nval>daysInMonth[yyyymmdd[1] - 1]||nval<1 ? ` error DD:1-${daysInMonth[yyyymmdd[1] - 1]}`: lineData[mfield])
                      break
                  case 3:  ///Hour
                      lineData[field]=lineData[field]+String(nval)+":"
                      lineData[mfield] = (isNaN(nval)?" error hour:  0-24":nval>24||nval<0?" error hour: 0-24":lineData[mfield])
                      break
                  case 4:  ///minitus
                      lineData[field]=lineData[field]+String(nval)+":"
                      lineData[mfield] = (isNaN(nval)? " error min:  0-59":nval>59||nval<0?" error min: 0-59":lineData[mfield] )
                      break
                  case 5:  ///second
                      lineData[field]=lineData[field]+String(nval)
                      lineData[mfield] = (isNaN(nval)? " error second:  0-59":nval>59||nval<0?" error second: 0-59":lineData[mfield] )
                      break}})
                  lineData[field] = lineData[field].replace(" 0:0:0","")
          }else{
                  lineData[mfield] = ` field:${field} not string`}
      }else{
          switch(field){
            case "screen_rowlist":  //一画面に表示できる行数をセットする項目の指定が正しくできているか？
                lineData[field].split(',').map((rowcnt)=>{
                    if(isNaN(rowcnt)){ 
                        lineData[mfield] = " must be xxx,yyy,zzz :xxx-->numeric"
                      }else{
                        if(lineData[mfield]){
                            if(/error/.test(lineData[mfield])){lineData[mfield] = " not numeric"}
                            else{lineData[mfield] = "ok"}
                             }
                        else{lineData[mfield] = "ok"}
                      } //エラーセット
                    return lineData
                })
              break
            case "screenfield_indisp":  //変更可能な　/_code/は必須項目。tipが機能しない。
                if(/_code/.test(lineData["pobject_code_sfd"])&&String(lineData["screenfield_editable"])==="1")
                    {if(String(lineData["screenfield_indisp"])==="1") //excelが数字を自動変換してしまう
                            {lineData[mfield] = "ok"}
                      else{lineData[mfield] = ` must be Required(indisp===1) `
                            }
                }else{
                            lineData[mfield] = "ok"}
              break
            default:
              lineData[mfield] = "ok"
              break
          }
         }
    }else{  //yupに登録されてないとき
      lineData[mfield] = ` field:${field} not exists in yupschema. please creat 'yupschema' by yup button `
    }
    return lineData
}

// function checkDate(year, month, day) {// 月ごとの最大日数
// 	if (!year || !month || !day){return false}
//   const daysInMonth = [31, isLeapYear(year) ? 29 : 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
//   if (year < 2000 || year > 2099 || day < 0 || day >  daysInMonth[month - 1] ){return false} 
// 	//if (!String(year).match(/^[0-9]{4}$/) || !String(month).match(/^[0-9]{1,2}$/) || !String(day).match(/^[0-9]{1,2}$/)) return false

// 	let dateObj      = new Date(year, month - 1, day),
// 	    dateObjStr   = dateObj.getFullYear() + '' + (dateObj.getMonth() + 1) + '' + dateObj.getDate(),
// 	    checkDateStr = year + '' + month + '' + day

// 	if (dateObjStr === checkDateStr){return true}else{return false}
// }

// うるう年の判定
function isLeapYear(year) {
  return (year % 4 === 0 && year % 100 !== 0) || (year % 400 === 0)
}
