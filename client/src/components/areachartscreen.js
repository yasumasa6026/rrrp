
import React, { useMemo } from 'react'
import {  useSelector } from 'react-redux'
import { AreaChart, Area, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from 'recharts'

const AreaChartScreen = () => {

  const screenCode = useSelector((state) => state.screen.params.screenCode)
  const data = useSelector((state) => state.screen.data)

  const areadata = useMemo(() => [])
  const nameKeyDuedate = screenCode.split('_')[1].slice(0, -1) + '_duedate'
  let sch
  let ord
  let act
  switch (true) {
    case /payalls/.test(screenCode):
      sch = screenCode.split('_')[1].slice(0, -1) + '_amt_sch'
      ord = screenCode.split('_')[1].slice(0, -1) + '_amt'
      act = screenCode.split('_')[1].slice(0, -1) + '_cash'
      break
    case /billalls/.test(screenCode):
      sch = screenCode.split('_')[1].slice(0, -1) + '_amt_sch'
      ord = screenCode.split('_')[1].slice(0, -1) + '_amt'
      act = screenCode.split('_')[1].slice(0, -1) + '_cash'
      break
    default:
      nameKeyLocaode = ''
  }
  data.map((rec, idx) => {
    return areadata[idx] = {
      name: rec[nameKeyDuedate],
      sch: parseInt(rec[sch].replace(/,/g, '')),
      ord: parseInt(rec[ord].replace(/,/g, '')),
      act: parseInt(rec[act].replace(/,/g, ''))
    }
  })
  return (
    <div>
      AreaChartScreen
      {/* <ResponsiveContainer width="100%" height="100%">  これがあると、なぜかひょうじされない。 */}
      <AreaChart
        width={1000}
        height={400}
        data={areadata}
        margin={{
          top: 10,
          right: 30,
          left: 100,
          bottom: 0
        }}
      >
        <CartesianGrid strokeDasharray='3 3' />
        <XAxis dataKey='name' />
        <YAxis />
        <Tooltip />
        <Area type='monotone' dataKey='sch' stackId='1' stroke='#8884d8' fill='#8884d8' />
        <Area type='monotone' dataKey='ord' stackId='1' stroke='#82ca9d' fill='#82ca9d' />
        <Area type='monotone' dataKey='act' stackId='1' stroke='#ffc658' fill='#ffc658' />
      </AreaChart>
      {/* </ResponsiveContainer> */}
    </div>
  )
}


export default AreaChartScreen
