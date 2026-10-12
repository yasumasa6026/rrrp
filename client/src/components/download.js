import React from 'react'
import { useSelector,} from 'react-redux'

const Download = () => {
  const params = useSelector((state) => state.screen.params)
  const filtered = params.filtered ? params.filtered : []
  const totalCount = useSelector((state) => state.button.totalCount)
  return (
    <div>
      <form>
        <p>DownLoad ScreenName:{params.screenName}</p>
        <p>select condition </p>
        {filtered.length === 0
          ? <p>all data selected </p>
          : filtered.map((val, idx) => {
            return <p key={idx}>{JSON.parse(val).id} : {JSON.parse(val).value}</p>
          })}
        <p>total record count {totalCount}</p>
      </form>
    </div>
  )
}

export default Download
