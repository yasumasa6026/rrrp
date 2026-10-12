import React, { useEffect, useState } from 'react'
import {  useSelector, useDispatch } from 'react-redux'
import { useForm } from 'react-hook-form'
import { setClassFunc, setProtectFunc } from './functions7'
import { onBlurFunc7, onFieldValite, fetchCheck } from './onblurfunc'
import { yupschema } from '../yupschema'
import { ScreenConfirm, FetchRequest } from '../actions'
import { yupErrCheck } from './yuperrcheck'
import '../index.css'
import { TableGridStyles } from '../styles/tablegridstyles'


  const setFormFieldByonBlur = (dispatch,e, fld,fetchOrCheck,params,lineData) => {
    let tmpline = { ...lineData, [fld.id]: e.target.value } // [id] idの内容
    const msg_id = `${lineData[fld.id]}_gridmessage`
    tmpline[`${lineData[fld.id]}_gridmessage`] = 'ok'
    tmpline = onFieldValite(tmpline, fld.id, params.screenCode) // clientでのチェック
    if (tmpline[msg_id] === 'ok') {
      tmpline = onBlurFunc7(params.screenCode, tmpline, lineData[fld.id])
    }
    if (tmpline[msg_id] === 'ok') {
      const { fetchCheckFlg, idKeys } = fetchCheck(tmpline, fld.id, fetchOrCheck)
      params = {
        ...params,
        fetchCode: JSON.stringify(idKeys),
        checkCode: JSON.stringify({ [fld.id]: fetchOrCheck.checkCode[fld.id] }),
        lineData: JSON.stringify(newRow),
        fetchview: fetchCheckFlg === 'fetch_request' ? fetchOrCheck.fetchCode[fld.id] : '',
        index: lineNo,
        buttonflg: fetchCheckFlg
      }

      if (fetchCheckFlg) { dispatch(FetchRequest(params))} else {
        Object.keys(lineData).map((field) => {
          if (tmpline[field] === '' || tmpline[field] === undefined) { tmpline[field] = lineData[field] }
        }
        )
        setLinedata({ ...tmpline })
      }
    } else {
      return (errormsg = tmpline[msg_id])
    }
    data[lineNo] = { ...lineData }
  }

  const TdInput = ({ screen,lineData, fld,register,getValues,dispatch }) => {
    const fetchOrCheck = screen.grid_columns_info.fetchOrCheck
    const params = screen.params
    const dropDownList = screen.grid_columns_info.dropDownList
    const ftypeValue = getValues('fieldcode_ftype')
    const typeValue = getValues('screenfield_type')
    switch (true) {
      case /^Editable/.test(fld.className):
        return (
          <input
            {...register(fld.id, { onBlur: (e) => setFormFieldByonBlur(dispatch,e, fld,fetchOrCheck,params,lineData), 
                          value: lineData[fld.id] })}
            className={setClassFunc(fld.id, lineData, fld.className, params.buttonflg)}
            readOnly={ftypeValue
              ? (setProtectFunc(fld.id, ftypeValue))
              : typeValue ? (setProtectFunc(fld.id, typeValue)) : false}
          />
        )
      case /SelectEditable/.test(fld.className):
        return (
          <select {...register(fld.id, { value: lineData[fld.id] })}>
            {typeof (dropDownList[fld.id]) !== 'undefined' && JSON.parse(dropDownList[fld.id]).map((option, i) => (
              <option key={i + 'op1'} value={option.value}>
                {option.label}
              </option>
            ))}
          </select>
        )
      case /CheckEditable/.test(fld.className):
        return (<input type='checkbox' {...register(fld.id, { value: lineData[fld.id] })} />)
      case /^NonEditable/.test(fld.className):
        return (<input {...register(fld.id, { value: lineData[fld.id] })} readOnly style={{ visibility: fld.hideflg }} />)
      case /SelectNonEditable/.test(fld.className):
        return (
          <select value={lineData[fld.id]} disabled>
            {
                                    typeof (dropDownList[fld.id]) !== 'undefined' && JSON.parse(dropDownList[fld.id]).map((option, i) => (
                                      <option key={i + 'op2'} value={option.value}>
                                        {option.label}
                                      </option>
                                    ))
                                }
          </select>
        )
      case /CheckNonEditable/.test(fld.className):
        return (<input value={lineData[fld.id]} type='checkbox' readOnly />)
      default:
        return (<input value={lineData[fld.id]} style={{ visibility: fld.hideflg }} readOnly />)
    }
  }

const buttonTitle = (params) => {
    switch (params.aud) {
      case 'edit':
        return ('Edit Confirm')
      case 'add':
        return ('Add Confirm')
      case 'delete':
        return ('Delete Confirm')
      default:
        return ('')
    }
  }
  
  


const ToSubForm = () => {
  // ★ dispatch 関数を取得
  const dispatch = useDispatch()  // ★ 必要な Redux state を直接取得

  const screen = useSelector((state) => state.screen)
  const params = screen.params
  const data = screen.data
  const subFormInfo = screen.grid_columns_info.subFormInfo
  const { handleSubmit, register, getValues, setValue } = useForm()

  const index = params.index
  const [lineNo, setLineNo] = useState(index < 0 ? 0 : index)
  useEffect(() => {setLineNo((index) => index < 0 ? 0 : index)},[index])
  const [lineData, setLinedata] = useState(data[lineNo])
  useEffect(() => {
    setLinedata(data[lineNo])
  },[lineNo])
  const pageChange = (cnt) => {
    subFormInfo.map((sub) => {
      sub.map((fld) => { setValue(fld.id, data[cnt][fld.id]) }
      )
    })
  }

  const onFormValite = () => {
    const Yup = require('yup')
    const screenSchema = Yup.object().shape(yupschema[params.screenCode])
    let checkFields = {}
    Object.keys(screenSchema.fields).map((field) => {
      checkFields[field] = lineData[field]
      return checkFields // 更新可能項目のみをセレクト
    })
    checkFields = yupErrCheck(screenSchema, 'confirm', checkFields)
    Object.keys(checkFields).map((field) => lineData[field] = checkFields[field])
    if (lineData.confirm_gridmessage === 'doing') {
      params = {
        ...params,
        lineData: JSON.stringify(lineData),
        index: lineNo,
        buttonflg: 'confirm7'
      }
      data[lineNo] = { ...lineData }
      dispatch(ScreenConfirm(params, data))
    }
  }


  let errormsg

  
  return (
    <div>
      <h3>{params.screenName}</h3>
      <form onSubmit={handleSubmit(() => onFormValite(dispatch,params))}>
        <button
          type='button' onClick={() => {
            pageChange(lineNo - 1) // lineNoは使用できない。React の仕様で state は次のレンダリングされるタイミングまで反映しない
            setLineNo(lineNo - 1)
          }} disabled={lineNo === 0}
        >
          {'<'}
        </button>
        <button
          type='button' onClick={() => {
            pageChange(lineNo + 1)
            setLineNo(lineNo + 1)
          }} disabled={lineNo > (data.length - 2)}
        >
          {'>'}
        </button>
        <TableGridStyles>
          <table width='100%' border-spacing='1'>
            <thead className='subtablehead'>
              <tr className='subtablehead'>
                <p>{[...Array(30)].map((dummyLow, didx) => (<th width='9%' key={didx + 'th'} />))}</p>
              </tr>
            </thead>
            <tbody>
              {subFormInfo.map((sub, trid) => {
                return (
                  <tr key={trid + 'tr'}>
                          {sub.map((fld, idx) => {
                          return (
                          <React.Fragment>
                              <td key={idx + 'td1'} className='subformtdlabel' style={{ visibility: fld.hideflg }}>{fld.label}</td>
                              <td rowSpan={fld.edoptrow} key={idx + 'td2'}>
                              <TdInput screen={screen} lineData={lineData}
                                        fld={fld}
                                        register={register}
                                        getValues={getValues} 
                                        dispatch={dispatch} />
                            </td>
                            </React.Fragment>
                          )
                        })}
                        </tr>
                )
              })}
            </tbody>
          </table>
        </TableGridStyles>
        {buttonTitle(params).length > 1 && <button>{buttonTitle(params)}</button>}<span>{' '}</span><span>{errormsg}</span>
      </form>
    </div>
  )
}

export default ToSubForm
