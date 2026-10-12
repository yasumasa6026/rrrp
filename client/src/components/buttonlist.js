import React, { useState } from 'react'
import {  useSelector, useDispatch } from 'react-redux'
import { Tab, Tabs, TabList, TabPanel } from 'react-tabs'
import UploadExcel from './uploadexcel.js'
import Download from './download'
import Pdf from './pdf'
import GanttTask from './gantttask.tsx'
import 'react-tabs/style/react-tabs.css'
import { Button } from '../styles/button'
import '../index.css'
import {
  ScreenRequest, DownloadRequest, UploadExcelInit, GanttChartRequest,
  ButtonFlgRequest, ScreenFailure, PdfRequest, 
  SecondConfirmAllRequest, YupRequest, TblfieldRequest, ResetRequest
} from '../actions'


const doButtonLists = (buttonCode, params, data, auth,screenFlg,dispatch) => {
    const screenData = []
    let newRow = {}
    let clickIndex = []
    let clickcnt = 0
    switch (buttonCode) { // buttonCode === button_code
      case 'search':
        params = { ...params, buttonflg: 'viewtablereq7', disableFilters: false, screenFlg: screenFlg, aud: 'view' }
        return dispatch(ScreenRequest(params, null)) // break

      case 'inlineedit7':
        params = { ...params, buttonflg: 'inlineedit7', disableFilters: false, screenFlg: screenFlg, aud: 'edit' }
        return dispatch(ScreenRequest(params, null)) //

      case 'inlineadd7':
        params = { ...params, pages: 1, buttonflg: 'inlineadd7', disableFilters: true, screenFlg: screenFlg, aud: 'add' }
        return dispatch(ScreenRequest(params, null)) //

      case 'showdetail':
        // case "adddetail":
        params.clickIndex && params.clickIndex.map((click) => {
          if (click.id) {
            clickcnt = clickcnt + 1
            params.head = { lineId: click.lineId, id: click.id, pareScreenCode: click.screenCode }
          }
        }
        )
        if (clickcnt === 1) {
          params = { ...params, buttonflg: buttonCode, disableFilters: false, screenFlg: 'second', aud: 'view' }
          return dispatch(ScreenRequest(params, null))
        } else { return dispatch(ScreenFailure('no select or duplicated select')) }
        // break

      case 'confirmAll'://
        params.clickIndex && params.clickIndex.map((click) => {
          if (click.sNo) { clickcnt = clickcnt + 1 }
        }
        )
        if (clickcnt > 0) {
          params = { ...params, buttonflg: 'confirmAll', aud: 'add', disableFilters: true, screenFlg: screenFlg }
          return dispatch(ScreenRequest(params, null)) //
        } else {
          return dispatch(ScreenFailure('please select and confirmall '))
        }

      case 'delAllShpords':// 第二画面専用
      case 'delAllShpdlvs':// 第二画面専用
      case 'delAllShpacts':// 第二画面専用
        params = { ...params, buttonflg: buttonCode, disableFilters: true, screenFlg: screenFlg }
        return dispatch(SecondConfirmAllRequest(params, null)) //

      case 'confirmShpacts':// 第二画面専用
        params = { ...params, buttonflg: 'confirmShpacts', disableFilters: true, screenFlg: screenFlg }
        return dispatch(SecondConfirmAllRequest(params, null)) //

      case 'confirmShpdlvs': // 第二画面専用
        params = { ...params, buttonflg: 'confirmShpdlvs', disableFilters: true, screenFlg: screenFlg }
        return dispatch(SecondConfirmAllRequest(params, null)) //

      case 'ganttchart':
        if (typeof (params.index) === 'number') {
          if (params.index < 0) { alert('please select') } else {
            params = { ...params, lineData: data[params.index], viewMode: 'Day', buttonflg: 'ganttchart', screenFlg: screenFlg }
            if (screenFlg === 'first') { return dispatch(GanttChartRequest(params)) } else { alert('GanttChart not support second screen  ') }
          }
        }//
        else { alert('please select') }
        break

      case 'reversechart':
        if (typeof (params.index) === 'number') {
          if (params.index < 0) { alert('please select') } else {
            params = { ...params, lineData: data[params.index], viewMode: 'Day', buttonflg: 'reversechart' }
            if (screenFlg === 'first') { return dispatch(GanttChartRequest(params, auth)) } else { alert('GanttChart not support second screen  ') }
          }//
        } else { alert('please select') }

      case 'MkPackingListNo'://
        params.clickIndex && params.clickIndex.map((click) => {
          if (click.sNo) { clickcnt = clickcnt + 1 }
        }
        )
        if (clickcnt > 0) {
          params = { ...params, buttonflg: 'MkPackingListNo', disableFilters: true, screenFlg: screenFlg }
          return dispatch(ScreenRequest(params, null)) //
        } else {
          return dispatch(ScreenFailure('please select and push MkPackingListNo_button'))
        }
      case 'MkInvoiceNo'://
        params = { ...params, buttonflg: 'MkInvoiceNo', disableFilters: true, screenFlg: screenFlg }
        return dispatch(ScreenRequest(params, null)) //

      case 'download':
        params = { ...params, buttonflg: 'download', disableFilters: false, screenFlg: screenFlg }
        return dispatch(DownloadRequest(params, auth)) //

      case 'upload':
        params = { ...params, buttonflg: 'upload', disableFilters: false, screenFlg: screenFlg }
        return dispatch(UploadExcelInit(params, auth)) //

      case 'mkShpords': // 第一画面で選択された親より第二画面表示
      case 'fordlvShpords': // 第一画面で選択された親より第二画面表示
      case 'ref_shpords': // 第一画面で選択された親より第二画面表示
      case 'ref_shpdlvs': // 第一画面で選択された親より第二画面表示
      case 'ref_shpacts': // 第一画面で選択された親より第二画面表示
      case 'foractShpdlvs': // 第一画面で選択された親より第二画面表示
      case 'prdDvsords': // 第一画面で選択された親より第二画面表示
      case 'prdDvsinsts': // 第一画面で選択された親より第二画面表示
      case 'prdDvsacts': // 第一画面で選択された親より第二画面表示
      case 'prdErcords': // 第一画面で選択された親より第二画面表示
      case 'prdErcinsts': // 第一画面で選択された親より第二画面表示
      case 'prdErcacts': // 第一画面で選択された親より第二画面表示
      case 'MkCalendars':
        clickIndex = params.clickIndex
        if (clickIndex.length > 0) { // if(params.clickIndex.length===0)  ---> error
          params = { ...params, lineData: {}, buttonflg: buttonCode, disableFilters: false, screenFlg: screenFlg }
          return dispatch(ScreenRequest(params, null))
        } else {
          return dispatch(ScreenFailure('please  select Order ', ''))
        }//
      case 'rejections': // 第一画面で選択された親より第二画面表示
        clickIndex = params.clickIndex
        if (clickIndex.length === 1) { // if(params.clickIndex.length===0)  ---> error
          params = { ...params, lineData: {}, buttonflg: buttonCode, disableFilters: false, screenFlg: screenFlg }
          return dispatch(ScreenRequest(params, null))
        } else {
          return dispatch(ScreenFailure('please  select Order or please  select only one record', ''))
        }//
      case 'samplePdf': //
        params = { ...params, listNamePdf: 'sampleList', buttonflg: buttonCode }
        return dispatch(PdfRequest(params, auth))
      case 'crt_tbl_view_screen':
        data.map((row, index) => {
          Object.keys(row).map((field, idx) => {
            if (/_code|_expiredate/.test(field)) { newRow = { ...newRow, [field]: row[field] } }
          })
          screenData[index] = newRow
          newRow = {}
        })
        params = { ...params, buttonflg: 'createTblViewScreen', data: screenData, messages: [], screenFlg: screenFlg }
        return dispatch(TblfieldRequest(params, auth)) //

      case 'unique_index':
        data.map((row, index) => {
          Object.keys(row).map((field, idx) => {
            if (/_code|_seqno|_grp|_expiredate/.test(field)) { newRow = { ...newRow, [field]: row[field] } }
          })
          screenData[index] = newRow
          newRow = {}
        })
        params = { ...params, buttonflg: 'createUniqueIndex', messages: [], data: screenData, screenFlg: screenFlg }
        return dispatch(TblfieldRequest(params, auth))

      case 'yup':
        params = { ...params, buttonflg: 'yup', disableFilters: true, screenFlg: screenFlg }
        return dispatch(YupRequest(params, auth)) //

      case 'reset':
        params = { ...params, buttonflg: 'reset', disableFilters: false, screenFlg: screenFlg, aud: '' }
        return dispatch(ResetRequest(params)) //

      default:
        return dispatch(ScreenFailure(` button not Supported ${buttonCode}`))
    }
  }

const ButtonList = ({ screenFlg }) => {
  // ★ dispatch 関数を取得
  const dispatch = useDispatch()  // ★ 必要な Redux state を直接取得
  const [contents, setContents] = useState(null)
  const auth = useSelector((state) => state.auth)
  const buttonListData = useSelector((state) => state.button.buttonListData)
  const loading = useSelector((state) => state.button.loading)
  const params = useSelector((state) => screenFlg === 'second'?state.second.params:state.screen.params)
  const data = useSelector((state) => screenFlg === 'second'?state.second.data:state.screen.data)
  const screenCode = params.screenCode
  return (
    <div>
      {buttonListData && // 画面のボタンが用意されてないときはskip
        <Tabs forceRenderTabPanel defaultIndex={0} selectedTabClassName='react-tabs--selected_custom_footer'>
          <TabList>
            {buttonListData.map((bList, idx) =>
              bList.screen_code === screenCode &&
                <Tab key={idx}>
                  <Button
                    type='submit'
                    onClick={(e) => {
                          if (e.shiftKey) { setContents(bList.usebutton_contents) } else {
                            setContents(null)
                            dispatch(ButtonFlgRequest(bList.button_code, params)) //
                            doButtonLists(bList.button_code, params, data, auth,screenFlg,dispatch)
                          }
                        } //
                                     }
                  >
                    {bList.button_title}
                  </Button>
                </Tab>)}
          </TabList>
          {buttonListData.map((bList, idx) =>
            bList.screen_code === screenCode &&
              <TabPanel key={idx}>
                <p />
              </TabPanel>)}
        </Tabs>}

      {(params.buttonflg === 'ganttchart' || params.buttonflg === 'reversechart') && screenFlg === params.screenFlg &&
        <div style={{ width: 'stretch' }}><GanttTask /> </div>}
      {params.buttonflg === 'upload' && <UploadExcel />}
      {params.buttonflg === 'download' && <Download />}
      {params.buttonflg.endsWith('Pdf') && <Pdf />}
      {(params.buttonflg === 'createTblViewScreen' || params.buttonflg === 'createUniqueIndex') && params.messages.map((msg, index) => {
        return <p key={index}>{msg}</p>
      }
      )}
      {loading && <p>loading</p>}
      {contents && (<p>{contents}</p>)}
    </div>
  )
}

export default ButtonList
