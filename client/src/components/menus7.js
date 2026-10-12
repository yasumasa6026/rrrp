// https://github.com/reactjs/react-tabs
// import axios from 'axios'
import React, { useState, } from 'react'
import { useSelector, useDispatch} from 'react-redux'
import { Tab, Tabs, TabList, TabPanel } from 'react-tabs'
import 'react-tabs/style/react-tabs.css'
import { Button } from '../styles/button'
import '../index.css'

import Login from './login'
import { ScreenInitRequest } from '../actions'
import ScreenGrid7 from './screengrid7'
import ButtonList from './buttonlist'

const titleNameSet = (screenName) => {
  return (
    document.title = `${screenName}`
  )
}

const Menus7 = () => {
  // ★ dispatch 関数を取得
  const dispatch = useDispatch()  // ★ 必要な Redux state を直接取得
  const auth = useSelector((state) => state.auth)
  const menu = useSelector((state) => state.menu)
  const screen = useSelector((state) => state.screen)
  const second = useSelector((state) => state.second)
  const [tabIndex, setTabIndex] = useState(0)
  const [subTabIndex, setSubTabIndex] = useState(0)
  const [contents, setContents] = useState(null)
  if (auth.isAuthenticated) {
    if (menu.menuListData) {
      const tmpgrpscr = [] // グルーブ化されたメニュー
      let ii = 0
      let lastGrp_name = ''
      menu.menuListData.map((cate, idx) => {
        if (lastGrp_name !== cate.grp_name) {
          tmpgrpscr[ii] = cate.grp_name
          lastGrp_name = cate.grp_name
          ii += 1
        }
      })

      // titleNameSet(tmpgrpscr[tabIndex])
      return (
        <div>
          <Tabs
            selectedIndex={tabIndex} onSelect={(changeTabIndex) => {
              setTabIndex(changeTabIndex)
              // 別のメニューの残存を消去する。
              setSubTabIndex(-1)
            }}
            selectedTabClassName='react-tabs--selected_custom_head'
          >
            <TabList>
              {tmpgrpscr.map((val, idx) => {
                return (
                  <Tab key={idx}>
                    {val}
                  </Tab>
                )
              }
              )}
            </TabList>
            {tmpgrpscr.map((val, idx) =>
              <TabPanel key={idx} />)}
          </Tabs>
          <Tabs
            forceRenderTabPanel selectedTabClassName='react-tabs--selected_custom_detail'
            selectedIndex={subTabIndex} onSelect={(changeTabIndex) => {
              setSubTabIndex(changeTabIndex)
            }}
          >
            <TabList>
              {menu.menuListData.map((val, idx) =>
                tmpgrpscr[tabIndex] === val.grp_name &&
                  <Tab key={idx}>
                    <Button
                      type='submit'
                      onClick={(e) => {
                        if (e.shiftKey) { setContents(val.contents) } else {
                          setContents(null)
                          titleNameSet(val.scr_name) // cromeのtab表示
                          let newParams = {
                              screenName: '',
                              disableFilters: false,
                              parse_linedata: {},
                              aud: 'view',
                              filtered: [],
                              where_str: '',
                              sortBy: [],
                              groupBy: [],
                              aggregated: [],
                              screenFlg: 'first',
                              screenCode: val.screen_code,
                              pageIndex: 0,
                              pageSize: 20,
                              index: -1,
                              clickIndex: [],
                              err: null,
                              buttonflg: 'viewtablereq7',
                              viewName: val.view_name
                            }
                          dispatch(ScreenInitRequest(newParams, auth))
                        }
                      }}
                    >
                      {val.scr_name}
                    </Button>
                  </Tab>)}
            </TabList>
            {menu.menuListData.map((val, idx) =>
              tmpgrpscr[tabIndex] === val.grp_name &&
                <TabPanel key={idx}>
                  <p />
                </TabPanel>)}
          </Tabs>
          {contents && (<div>{contents}</div>)}
          {menu.firstView && <div> <ScreenGrid7 screenFlg='first' /></div>}
          {
                  //  第一画面
               }
          {!screen.toggleSubForm && <div> <ButtonList screenFlg='first' /></div>}
          {menu.firstView && screen.loading && (<div colSpan='10000'>
            Loading...
          </div>)}
          {!menu.firstView && !menu.secondView && menu.menuMessage && (<div colSpan='10000'>
            {menu.menuMessage}
                                                        </div>)}
          {menu.firstView && menu.message && (<div colSpan='10000'>
            {menu.message}
                                    </div>)}
          {menu.firstView && menu.hostError && (<div colSpan='10000'>
            {menu.hostError}
                                      </div>)}
          {
                  // 第二画
              }
          {menu.secondView && <p> {second.params.screenName} </p>}
          <div> {menu.secondView ? <ScreenGrid7 screenFlg='second' /> : ''}</div>
          {menu.secondView && !second.toggleSubForm && <div> <ButtonList screenFlg='second' /></div>}
          {second.loading && (<div colSpan='10000'>
            Loading.....
          </div>)}
          {menu.secondView && menu.message && (<div colSpan='10000'>
            {menu.message}
                                     </div>)}
          {menu.secondView && menu.hostError && (<div colSpan='10000'>
            {menu.hostError}
                                       </div>)}
        </div>
      )
    } else {
      return (
        <div>
          {screen.loading ? <p> doing{menu.hostError || ''} </p> : <p> please logout because no data </p>}
        </div>
      )
    }
  } else {
    return (
      <div>
        <p> {menu.hostError || ''} </p>
        <Login />
      </div>
    )
  }
}

export default Menus7
