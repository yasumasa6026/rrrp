import React from 'react'
import { useSelector, useDispatch  } from 'react-redux'
import { UploadExcelRequest } from '../actions'

const UploadExcel = () => {
  // ★ dispatch 関数を取得
  const dispatch = useDispatch()  // ★ 必要な Redux state を直接取得
  const upload = useSelector((state) => state.upload)
  const nameToCode = useSelector((state) => state.screen.grid_columns_info.nameToCode)
  const params = useSelector((state) => state.screen.params)
  const auth = useSelector((state) => state.auth)
  return (
    <>
      <div className='has-text-right buttons-padding'>
        <label htmlFor='inputExcel'>
          <input
            type='file' id='inputExcel'
            accept='application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
                      /* disabled={!ready} */
            placeholder='Excel File or Csv File'
            onChange={ev => {
              if (ev.currentTarget.files[0]) {
                const excelfile = ev.currentTarget.files[0]
                const excelfilename = excelfile.name
                if (excelfilename.search(/\.xlsx$|\.csv$/)) { dispatch(UploadExcelRequest({ excelfile, nameToCode, params, auth })) } 
                // .xlsx  は　controllers/api/uploadでも使用
                else {
                  alert('please input Excel File or Csv File')
                }
              }
            }}
          />
        </label>

      </div>
      <div>
        {upload.formatError === true && <p>error please check  file format</p>}
        {upload.uploadErrorCheckMaster === true && <p> error  </p>}
        {upload.uploadError === true && <p> some records have errors (skiped  all data(rollback done))  </p>}
        {upload.normalEnd === true && <p>  Add or Update records {upload.idx} </p>}
        {upload.errHeader && upload.errHeader.map((err) => { if (err) { return <p> Error:{err}  </p> } })}
      </div>
      {upload.errMessage}
    </>
  )
}

export default UploadExcel
