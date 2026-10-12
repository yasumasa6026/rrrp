//
//  typeof(xxx)==="undefined"の対応要
//
import React, { useState, useMemo, useEffect } from 'react'
import { useSelector, useDispatch} from 'react-redux'
import {
  ScreenConfirm, FetchRequest, ScreenSubForm, SecondSubForm, AreaChartRequest,
  SecondConfirm, SecondFetchRequest, ScreenDataSet, SecondDataSet
} from '../actions'
// import DropDown from './dropdown'
import { yupschema } from '../yupschema'
import { yupErrCheck } from './yuperrcheck'
//import { Tooltip } from 'react-tooltip'
import { onBlurFunc7, onFieldValite, fetchCheck } from './onblurfunc'
// import ButtonList from './buttonlist'
import {
  useTable, useRowSelect, useFilters, useGroupBy, useSortBy, useResizeColumns, useBlockLayout,
  useExpanded
  // useTokenPagination,  //usePagination,
} from 'react-table'
//  useTokenPagination   ---> undefined pluginが発生
// Some server-side pagination implementations do not use page index
// and instead use token based pagination! If that's the case,
// please use the useTokenPagination plugin instead
import { TableGridStyles } from '../styles/tablegridstyles'
import '../index.css'
import { setClassFunc, setProtectFunc, setYyyymmddFunc } from './functions7'
import ToSubForm from './tosubform'
import AreaChartScreen from './areachartscreen'

const cellFontSize = (column, para) => {
  let length
  let width
  let fontSize
  switch (para) {
    case 'Header':
      width = column.width
      length = column.Header.length
      if (typeof (column.Header) === 'string') {
        length = column.Header.match(/^[0-9a-zA-Z\-_:\s.]*$/) ? length * 1 : length * 1.8
      } else { length = 1 }
      break
    default:
      width = column.column.width
      if (typeof (column.value) === 'string') {
        length = column.value.length
        length = column.value.match(/^[0-9a-zA-Z\-_:\s.@#;()%]*$/) ? length * 1 : length * 1.5
      } else { length = 1 }
  }
  const checkFontSize = Math.ceil(width / length)
  if (checkFontSize > 10) { fontSize = 18 } else { fontSize = Math.ceil(width / length * 1.8) }
  return `${fontSize}px`
}

const AutoCell = ({
  value: initialValue,
  row: { index, values },
  column: { id, className }, // id field_code
  // setData,
  data, // This is a custom function that we supplied to our table instance
  // setChangeData,
  // baseData,
  row, params, dropDownList, fetchOrCheck, fetchCheck,
  buttonflg, // useTableへの登録が必要
  handleScreenRequest, handleFetchRequest, toggleSubForm, handleDataSetRequest
}) => {
  const setFieldsByonChange = (e) => {
    if (e.target) {
      values[id] = e.target.value
      updateMyData(index, id, values[id]) // dataの内容が更新されない。但しとると、画面に入力内容が表示されない。
      params = { ...params, index: index }
      handleDataSetRequest(data, params)
    }
  }

  const setFieldsByonBlur = (e) => {
    let lineData = { ...values, [id]: e.target.value } // [id] idの内容
    const msg_id = `${id}_gridmessage`
    lineData[msg_id] = 'ok'
    // let autoAddFields = {}
    lineData = onFieldValite(lineData, id, params.screenCode) // clientでのチェック
    if (lineData[msg_id] === 'ok') {
      lineData = onBlurFunc7(params.screenCode, lineData, id)
    }
    // updateMyData(index, msg_id, lineData[msg_id])
    // if ( (lineData[msg_id] === "ok"&baseData[index][id]!==data[index][id]) ||lineData[msg_id] === "error not detected" ) { // 変更項目のみ対象error not detected
    if ((lineData[msg_id] === 'ok' || lineData[msg_id] === 'error not detected')) {
      const { fetchCheckFlg, idKeys } = fetchCheck(lineData, id, fetchOrCheck)
      // updateMyData(index, {[id]:lineData[id],[msg_id]:lineData[msg_id]})
      if (fetchCheckFlg) {
        params = {
          ...params,
          fetchCode: JSON.stringify(idKeys),
          checkCode: JSON.stringify({ [id]: fetchOrCheck.checkCode[id] }),
          lineData: JSON.stringify(lineData),
          fetchview: fetchCheckFlg.split(',')[0] === 'fetch_request' ? fetchOrCheck.fetchCode[id] : '',
          index: index,
          buttonflg: fetchCheckFlg
        }
        handleFetchRequest(params, buttonflg)
      } else {}
    } else {}

    updateData(index, lineData)
    params = { ...params, index: index }
    handleDataSetRequest(data, params)
  }

  const onLineValite = (lineData, index, params) => {
    const Yup = require('yup')
    const screenSchema = Yup.object().shape(yupschema[params.screenCode])
    let checkFields = {}
    Object.keys(screenSchema.fields).map((field) => {
      checkFields[field] = lineData[field]
      return checkFields // 更新可能項目のみをセレクト
    })
    checkFields = yupErrCheck(screenSchema, 'confirm', checkFields)
    Object.keys(checkFields).map((field) => lineData[field] = checkFields[field])
    if (lineData.confirm_gridmessage && lineData.confirm_gridmessage === 'ok') {
      params = { ...params, lineData: JSON.stringify(lineData), index: index, buttonflg: 'confirm7' }
      handleScreenRequest(params, data)
    } else {
      const msg_id = 'confirm_gridmessage'
      lineData.errPath.map((gridmsg_id) =>
        updateData(index, { [msg_id]: ' error ' + lineData[msg_id], [gridmsg_id]: ' error ' + lineData[gridmsg_id], confirm: false })
      )
      handleDataSetRequest(data, params)
    }
  }

  const updateMyData = (rowIndex, columnId, value) => {
    data = data.map((row, index) => {
      if (index === rowIndex) {
        row = {
          ...row, [columnId]: value
        }
      }
      return row
    })
  }
  const updateData = (rowIndex, line) => {
    data = data.map((row, index) => {
      if (index === rowIndex) {
        row = { ...row, ...line }
      }
      return row
    })
  }

  switch (true) {
    case /^Editable/.test(className):
      return (
        <sp>
          {/* <a id={`${id}_${index}`} data-tooltip-content={`${data[index][id + '_gridmessage']}`}
                data-tooltip-html={`<div>${data[index][id + '_gridmessage']}</div>`}
                data-tooltip-id={`Tooltip_#${id}_${index}`}>
              */}
          <input
            value={initialValue} // value={initialValue||""}--> zeroが""になった
                   // placeholder(入力されたことにならない。) defaultvale（照会内容の残像が残る。)
            onChange={(e) => setFieldsByonChange(e)}
                     // onFocus={(e) => {setFieldsByonFocus(e)
                      //               }}
            readOnly={setProtectFunc(id, row.values)}
            onBlur={(e) => setFieldsByonBlur(e)}
            className={setClassFunc(id, data[index], className, params.aud)}
            onKeyUp={(e) => {
              if (e.key === 'Enter' && !toggleSubForm) {
                onLineValite(row.values, index, params)
              } else { e.key === 'Enter' && toggleSubForm && alert('can not use filer and sord when subForm using') }
            }}

            onClick={() => data[index][id + '_gridmessage'] && alert(data[index][id + '_gridmessage'])}
          />
          {/*    </a>
                <Tooltip id={`Tooltip_#${id}_${index}`}
                data-tooltip-offset={-30} style={{ backgroundColor: "rgb(0, 255, 30)", color: "#222" }} /> */}
        </sp>
      )
    case /SelectEditable/.test(className):
      return (
        <sp>
          <select
            value={initialValue || ''}
            onChange={e => {
              setFieldsByonChange(e)
            }}
            onBlur={(e) => setFieldsByonBlur(e)}
            className={setClassFunc(id, data[index], className, params.aud)}
          >
            {typeof (dropDownList[id]) !== 'undefined' && JSON.parse(dropDownList[id]).map((option, i) => (
              <option key={i} value={option.value}>
                {option.label}
              </option>
            ))}
          </select>
        </sp>
      )

    case /CheckEditable/.test(className):
      return (
        <input
          type='checkbox'
          onChange={e => {
            setFieldsByonChange(e)
          }}
          className={setClassFunc(id, data[index], className, params.aud)}
        />
      )
    case /^NonEditable/.test(className):
      return <span> {initialValue || ''} </span>

    case /SelectNonEditable/.test(className):
      return (
        <select value={initialValue || ''} disabled>
          {
              typeof (dropDownList[id]) !== 'undefined' && JSON.parse(dropDownList[id]).map((option, i) => (
                <option key={i} value={option.value}>
                  {option.label}
                </option>
              ))
}
        </select>
      )

    case /CheckNonEditable/.test(className):
      return <input value={initialValue || ''} type='checkbox' disabled='disabled' />

    case /checkbox/.test(className):
      const chekboxClassName = setClassFunc(id, row.values, className, params.aud)
      return (
        <sp>
          {/* <Tooltip content={data[index][`${id}_gridmessage`]||""}  anchorSelect={`#${id}_${index}`} /> */}
          <label htmlFor={`${id}_${index}`} className={chekboxClassName}>
            {chekboxClassName === 'checkbox' ? '' : 'error'}
          </label>
          <input
            type='checkbox' checked={data[index][id] === true ? 'checked' : ''}
            id={`${id}_${index}`}
            className={chekboxClassName}
            onClick={() => data[index][id + '_gridmessage'] && alert(data[index][id + '_gridmessage'])}
            readOnly
          />
          {/*     style={{bakground:"red"}}が有効にならない。 */}
        </sp>
      )
    default:
      return <input value={initialValue || ''} readOnly />
  }
}

const DefaultColumnFilter = ({
  column: { filterValue, setFilter, filter, preFilteredRows, id },
  dropDownList
}) => {
  if (filter === 'includes') {
    return (
      <select
        value={filterValue || ''}
        onChange={e => {
          setFilter(e.target.value || '')
        }}
      >
        {typeof (dropDownList[id]) !== 'undefined' && JSON.parse(dropDownList[id]).map((option, i) => (
          <option key={i} value={option.value}>
            {option.label}
          </option>
        ))}
      </select>
    )
  } else {
    return (
      <input
        value={filterValue || ''}
        onChange={e => { // onBlur can not use
          setFilter(e.target.value || '')
        }}
      />
    )
  }
}

const ScreenGrid7 = ({screenFlg }) => {
  const dispatch = useDispatch()
  // ② useSelector の中で props の screenFlg をそのまま使って分岐！
  const currentScreenState = useSelector((state) =>
    screenFlg === 'second' ? state.second : state.screen
  )
  // 必要なプロパティを取り出す
  const {
    params,
    loading,
    data,
    toggleSubForm,
    grid_columns_info
  } = currentScreenState  
  const screenCode = params.screenCode
  const buttonflg = params.buttonflg
  const pageSizeList = grid_columns_info.pageSizeList
  const columns = grid_columns_info.columns_info
  const screenwidth = grid_columns_info.screenwidth
  const fetchOrCheck = grid_columns_info.fetchOrCheck
  const dropDownList = grid_columns_info.dropDownList
  const hiddenColumns = grid_columns_info.hiddenColumns
  // second 画面では AreaChart は非表示、first 画面なら state の値を採用
  const toggleAreaChart = screenFlg === 'second' ? false : currentScreenState.toggleAreaChart
  //
  const [groupBy,setGroupBy] = useState([])
  const [aggregations,setAggregations] = useState({})
  const [filters,setFilters] = useState([])
  const [sortBy, setSortBy] = useState([])
  useEffect(() => { setSortBy([]),setGroupBy([]),setAggregations({}),setFilters([])
                  }, [screenCode])
  const nextPage = () => {
    params.pageIndex = params.pageIndex + 1
    handleScreenRequest(params, data)
  }

  const previousPage = () => {
    params.pageIndex = params.pageIndex - 1
    handleScreenRequest(params, data)
  }

  const gotoPage = (page) => {
    if (Number(page) >= 0 && Number(page) < (Number(params.pageCount) + 1)) {
      params.pageIndex = (Number(page) - 1)
      // setControlledPageIndex(page)
      handleScreenRequest(params, data)
    } else {
    }
  }

  const canPreviousPage = () => { return params.pageIndex < 1 ? 0 : 1 }
  const canNextPage = () => { return (params.pageIndex + 1) < (Number(params.pageCount)) ? 1 : 0 }
  const toDelete = (params) => {
    if (params.index === null || params.index === undefined) { alert('please select target record') } else {
      params = { ...params, aud: 'delete' }
      handleSubForm(params, true)
    }
  }

  const handleScreenRequest = (params, data) => {
    const updateParams = { ...params, screenFlg}
    if (screenFlg === 'second') {
      dispatch(SecondConfirm(updateParams, data))
    } else {
      dispatch(ScreenConfirm(updateParams, data))
    }
  }
const handleFetchRequest = (params) => {
    params = { ...params, screenFlg}
    if (screenFlg === 'second') {
      dispatch(SecondFetchRequest(params))
    } else {
      dispatch(FetchRequest(params))
    }
  }
const handleSubForm = (params, toggleSubForm) => {
    if (screenFlg === 'second') {
      dispatch(SecondSubForm(toggleSubForm, params))
    } else {
      dispatch(ScreenSubForm(toggleSubForm, params))
    }
  }
const  handleAreaChart = (params, toggleAreaChart) => {
    if (Array.isArray(params.groupBy) && params.groupBy.find(ele => ele.match(/duedate/))) {
      if (screenFlg === 'first') {
        return dispatch(AreaChartRequest(toggleAreaChart, params))
      } else { if (screenFlg === 'second') { alert('AreaChart not support second screen  ') } }
    }//
    else { alert('GroupBy duedate (alt_key + duedate') }
  }
const handleDataSetRequest = (data, params) => {
    if (screenFlg === 'second') {
      dispatch(SecondDataSet(data, params))
    } else {
      dispatch(ScreenDataSet(data, params))
    }
  }

  return (
    <div>
      <TableGridStyles
        height={buttonflg ? '840px' : buttonflg === 'download' ? '500px' : buttonflg === 'import' ? '300px' : '840px'}
        screenwidth={screenwidth}
      >
        <GridTable
          columns={columns} screenCode={screenCode}
          data={data} dropDownList={dropDownList}
            // setChangeData={setChangeData}
            // baseData={baseData}
            // controlledPageIndex={controlledPageIndex}
            // controlledPageSize={controlledPageSize}
          buttonflg={buttonflg} loading={loading}
          pageSizeList={pageSizeList} fetchOrCheck={fetchOrCheck} fetchCheck={fetchCheck}
          params={params}
          sortBy={sortBy} filters={filters} groupBy={groupBy}
          aggregations={aggregations} // skipReset={skipResetRef.current}
          disableFilters={params.disableFilters} toggleSubForm={toggleSubForm}
          hiddenColumns={hiddenColumns} handleScreenRequest={handleScreenRequest}
          handleFetchRequest={handleFetchRequest} handleSubForm={handleSubForm} handleDataSetRequest={handleDataSetRequest}
          handleAreaChart={handleAreaChart}
          getHeaderProps={column => ({ // セルのサイズ合わせとclick　keyが重複するのを避けるため
            onClick: (e) => {
              if (e.ctrlKey) { // sort時はctrlKey　keyが必須
                switch (column.isSorted) {
                  case true:
                    switch (column.isSortedDesc) {
                      case false:
                        column.toggleSortBy(true, true) // sort:true desc:true
                        return
                      default:
                        column.clearSortBy() // sort:false
                        return
                    }
                  default:
                    column.toggleSortBy(false, true) // sort:true desc:false
                }
              } else {
                if (e.altKey && params.aud === 'view') {
                  switch (true) {
                    case /_qty|_amt|_cash/.test(column.id):
                      if (column.isGrouped) {
                        column.toggleGroupBy()
                      }//
                      else {
                        switch (aggregations[column.id]) {
                          case 'SUM:':
                            aggregations[column.id] = 'MAX:'
                            break
                          case 'MAX:':
                            aggregations[column.id] = 'MIN:'
                            break
                          case 'MIN:':
                            aggregations[column.id] = ''
                            column.toggleGroupBy() // )
                            break
                          default:
                            aggregations[column.id] = 'SUM:'
                        }
                      }
                      break
                    case /_price/.test(column.id):
                      if (column.isGrouped) {
                        column.toggleGroupBy()
                      }//
                      else {
                        switch (aggregations[column.id]) {
                          case 'MAX:':
                            aggregations[column.id] = 'MIN:'
                            break
                          case 'MIN:':
                            aggregations[column.id] = ''
                            column.toggleGroupBy() // )
                            break
                          default:
                            aggregations[column.id] = 'MAX:'
                        }
                      }
                      break
                    case /date$|_at$/.test(column.id): // group by  対象
                      if (column.isGrouped) {
                        switch (aggregations[column.id]) {
                          case 'MM:':
                            aggregations[column.id] = 'WW:'
                            break
                          case 'WW:':
                            aggregations[column.id] = 'DD:'
                            break
                          case 'DD:':
                            aggregations[column.id] = ''
                            column.toggleGroupBy() //
                            break
                          default:
                            aggregations[column.id] = 'MM:'
                        }
                      } else {
                        aggregations[column.id] = 'MM:'
                        column.toggleGroupBy() //
                      }
                      break
                    default:
                      column.toggleGroupBy() //
                      break
                  }
                  params = { ...params, groupBy: groupBy, aggregations: aggregations }
                  handleDataSetRequest(data, params)
                }
              }
            },
            style: { fontSize: cellFontSize(column, 'Header') }
          })}
          getCellProps={cell => ({
            style: { fontSize: cellFontSize(cell, 'Cell') }
          })}
        />
      </TableGridStyles>
      {params.aud !== 'add' && <div colSpan='10000' className='td'>
        {screenCode === ''
          ? ''
          : Number(params.totalCount) === 0
            ? 'No Record'
            : `Showing ${params.pageIndex * params.pageSize + 1} of ~
                 ${Number(params.totalCount) < ((params.pageIndex + 1) * params.pageSize)
                  ? Number(params.totalCount)
: ((params.pageIndex + 1) * params.pageSize)} 
                  results of  total ${Number(params.totalCount)} records`}
                               </div>}
      {(Number(params.totalCount) > 0 && !toggleSubForm) &&
        <span className='pagination'>
          <button
            onClick={() => {
              gotoPage(1)
            }} disabled={canPreviousPage() === 0}
          >
            {'<<'}
          </button>
          <button
            onClick={() => {
              previousPage()
            }} disabled={canPreviousPage() === 0}
          >
            {'<'}
          </button>
          <button
            onClick={() => {
              nextPage()
            }} disabled={canNextPage() === 0}
          >
            {'>'}
          </button>
          <button onClick={() => { gotoPage(Number(params.pageCount)) }} disabled={canNextPage() === 0}>
            {'>>'}
          </button>{' '}
          <span>
            Page{' '}
            <strong>
              {params.pageIndex + 1} of {(Number(params.pageCount))}
            </strong>
          </span>
          <span>
            | Go to page:
            <input
              type='number'
              value={params.pageIndex ? params.pageIndex + 1 : 1}
              onChange={e => {
                params.pageIndex = ((Number(e.target.value) - 1))
              }}
              onBlur={e => {
                gotoPage(e.target.value)
              }}
              onKeyUp={(e) => {
                if (e.key === 'Enter') {
                  gotoPage(e.target.value)
                }
              }}
              style={{
                width: '80px',
                height: '23px',
                textAlign: 'right'
              }}
            />
          </span>{' '}
          <select
            value={Number(params.pageSize || 0)}
            onChange={e => {
              // params.pageIndex = 1
              params = {
                ...params,
                pageSize: (Number(e.target.value)),
                pageIndex: (Math.floor(Number(params.totalCount) / params.pageSize * params.pageIndex))
              }
              handleScreenRequest(params, data)
            }}
          >
            {pageSizeList.map(pageSize => (
              <option key={pageSize} value={pageSize}>
                Show {pageSize}
              </option>
            )) /* menuから呼ばれたときはparams.pageSizeList==null　*/}
          </select>
          <span> {' '}</span>
        </span> /* nextPage等終わり */}
      <button
        onClick={() => {
          if (params.index === null || params.index === undefined) { params.index = 0 }
          handleSubForm(params, true)
        }}
        disabled={!!toggleSubForm}
      >ToSubForm
      </button>
      <span> {' '}</span>
      <button onClick={() => toDelete(params)} disabled={!!toggleSubForm}>Delete</button>
      <span> {' '}</span>

      <button
        onClick={() => { handleSubForm(params, false) }}
        disabled={!toggleSubForm}
      >Close_subForm
      </button>
      <span> {' '}</span>

      {/^linechart/.test(params.screenCode) && <button
        disabled={!!toggleAreaChart}
        onClick={() => {
          handleAreaChart(params, true) // toggleAreaChart=true
        } // toggle not function why?
                                    }
                                               >AreaChart
                                               </button>}
      <span> {' '}</span>
      {/^linechart/.test(params.screenCode) && <button
        disabled={!toggleAreaChart}
        onClick={() => {
          handleAreaChart(params, false) // toggleAreaChart=true
        } // toggle not function why?
                                    }
                                               >Close AreaChart
                                               </button>}

      {toggleSubForm && <ToSubForm />}

      {toggleAreaChart && <AreaChartScreen />}

      {screenCode === 'r_fieldcodes' && <p> 修正時には、再起動が必要</p>}
    </div>
  )
}

// Create a default prop getter
const defaultPropGetter = () => ({})

///
///
const GridTable = ({
  columns,
  data,
  dropDownList,
  // setChangeData,
  // baseData,
  fetchOrCheck,
  params, aggregations, // setAggregated,
  buttonflg, disableFilters, // loading,
  hiddenColumns, handleScreenRequest,
  handleFetchRequest, fetchCheck, toggleSubForm, handleSubForm, handleDataSetRequest,
  getHeaderProps = defaultPropGetter,
  // getColumnProps = defaultPropGetter,
  getCellProps = defaultPropGetter
  // skipReset,
}) => {
  // const [dropDownList, setDropDownList] = useState(dropDownListOrg)

  const ColumnHeader = ({
    column
  }) => {
    return (
      <span />
    )
  }

  const defaultColumn = useMemo(
    () => ({
      Header: ColumnHeader,
      Filter: DefaultColumnFilter,
      Cell: AutoCell
    }),
    []
  )

  { /*
    ###
    ###   同一カラムによるfilter,sortの重複解消処理、filter sortの前の状態表示
    ###
*/ }

  const {
    getTableProps,
    getTableBodyProps,
    headerGroups,
    rows,
    prepareRow,
    toggleAllRowsSelected,
    setAllFilters, setGroupBy, // aggregations, /*setSortBy, */
    state: { filters, sortBy, groupBy, selectedRowIds }
  } = useTable(
    {
      columns,
      data,
      // baseData,
      params,
      dropDownList,
      fetchOrCheck,
      fetchCheck,
      buttonflg,
      // setChangeData,
      defaultColumn,
      manualPagination: false,
      manualFilters: true,
      manualSortBy: true,
      manualGroupBy: true,
      disableMultiSort: false,
      autoResetSortBy: true,
      autoResetSelectedRows: true,
      autoResetFilters: true,
      disableFilters,
      initialState: { hiddenColumns: hiddenColumns, selectedRowIds: {} },
      handleFetchRequest,
      handleScreenRequest,
      toggleSubForm,
      handleDataSetRequest
    },
    useFilters, //
    useGroupBy,
    useSortBy, // The useSortBy plugin hook must be placed after the useFilters plugin hook!
    useBlockLayout,
    useResizeColumns,
    useExpanded,
    // usePagination,
    // useTokenPagination, //The usePagination plugin hook must be placed after the useSortBy plugin hook!
    useRowSelect
  )
  //
  
  useEffect(() => {
    setAllFilters(params.filtered
      ? params.filtered.map((filter) => {
          return (typeof (filter) === 'string' ? JSON.parse(filter) : filter)
        })
      : []),

    // setSortBy(params.sortBy?params.sortBy.map((sort)=>{
    //   return (typeof(sort)==="string"?JSON.parse(sort):sort)}):[])

    setGroupBy(params.groupBy
      ? params.groupBy.map((group) => {
          return (typeof (group) === 'string' ? JSON.parse(group) : group)
        })
      : [])
  }, [params.filtered,params.groupBy])


  return (
    <div>
      <table
        {...getTableProps({
          onClick: (e) => {}
        })} className='table'
      >
        <thead className='thead'>
          {headerGroups.map(headerGroup => (
            <tr
              {...headerGroup.getHeaderGroupProps({
                style: {
                  backgroundColor: 'gray'
                },
                onKeyUp: (e) => //
                { // filter sortでの検索しなおし
                  if (e.key === 'Enter' && !params.disableFilters && !toggleSubForm) {
                    setYyyymmddFunc(filters)
                    params = { ...params, aud: 'view', buttonflg: 'viewtablereq7', filtered: filters, sortBy: sortBy, groupBy: groupBy, aggregations: aggregations }
                    // Apply the header cell props
                    handleScreenRequest(params, data)
                  } else { e.key === 'Enter' && toggleSubForm && alert('can not use filer or sortBy or groupBy when subForm using') }
                },
                onClick: (e) => {
                }
              })
            } className='tr'
            >
              {headerGroup.headers.map(column => (
                <th
                  {...column.getHeaderProps([getHeaderProps(column)
                  ])} className='th'
                >
                  <span style={{ backgroundColor: 'red' }}>
                    {column.isGrouped ? 'Gr ' : ''}
                    {aggregations[column.id] ? aggregations[column.id] : ''}
                  </span>
                  {column.render('Header')}
                  <span>
                    {/* Use column.getResizerProps to hook up the events correctly   🛅 */}
                    {column.isSorted ? column.isSortedDesc ? ' 🔽' : ' 🔼' : ''}
                  </span>
                  {typeof (dropDownList) !== 'undefined' && column.canFilter && <span>
                    {column.render('Filter')}
                                                                                </span>}
                  <span {...column.getResizerProps()} className={`resizer ${column.isResizing ? 'isResizing' : ''}`} />
                </th>
              ))}
            </tr>
          ))}
        </thead>
        <tbody {...getTableBodyProps()} className='tbody'>
          {rows.map((row, i) => {
            prepareRow(row) // select rowを使用する時必須
            return (
              <tr
                {...row.getRowProps({
                  style: {
                    backgroundColor: row.isSelected ? 'lime'
                      // params.index === row.index?'lime' :
                      : row.index % 2 === 0 ? 'ivory' : 'lightgray'
                  },
                  onClick: e => {
                    // let result = -1
                    let sNo
                    switch (params.screenCode) {
                      case 'fmcustord_custinsts':
                        sNo = 'custinst_sno_custord'
                        break
                      case 'fmcustinst_custdlvs':
                        sNo = 'custdlv_sno_custinst'
                        break
                      default:
                        sNo = `${params.screenCode.split('_')[1].slice(0, -1)}_sno`
                    }
                    if (e.ctrlKey) { // 複数行選択
                      if (Object.keys(selectedRowIds).length === 0) {
                        toggleAllRowsSelected(true)
                        params = { ...params, clickIndex: [] }
                        data.map((line, idx) => params.clickIndex.push({
                          lineId: idx,
                          id: line.id,
                          screenCode: params.screenCode,
                          sNo: line[sNo]
                        })
                        )
                        params = { ...params, index: -1 }
                      } else {
                        toggleAllRowsSelected(false)
                        params = { ...params, clickIndex: [], index: -1 }
                      }
                    } else {
                      if (row.isSelected) {
                        row.toggleRowSelected(false)
                        params.clickIndex.map((click, idx) => {
                          if (click.lineId === row.index) { return params = { ...params, clickIndex: params.clickIndex.slice(idx, 1) } }
                        })
                      } else {
                        row.toggleRowSelected(true)
                        //  params = {...params,clickIndex:[]}
                        params.clickIndex.push({
                          lineId: row.index,
                          id: data[row.index].id,
                          screenCode: params.screenCode,
                          sNo: data[row.index][sNo]
                        })
                        params = { ...params, index: row.index, clickIndex: params.clickIndex }
                      }
                    }
                    // params = {...params,changeData:changeData}
                    toggleSubForm && handleSubForm(params, toggleSubForm)
                    handleDataSetRequest(data, params)
                  }
                })
                  }
                className='tr'
              >
                {row.cells.map(cell => { // cell.column.className  壱階層目の見出しを想定
                  return (
                    <td {...cell.getCellProps([{ className: cell.column.className + ' td ' },
                        getCellProps(cell) // font-sizeの調整
                      ])}
                      >
                        {typeof (dropDownList) !== 'undefined' && cell.render('Cell')}
                      </td>
                  )
                })}
              </tr>
            )
          })}
        </tbody>
      </table>
    </div>
  )
}

export default ScreenGrid7
