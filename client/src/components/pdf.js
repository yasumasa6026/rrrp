import {  useSelector, } from 'react-redux'

const Pdf = () => {
  const params = useSelector((state) => state.screen.params)
  const listTypePdf =  params.listTypePdf ? params.listTypePdf : ''
  const totalPagePdf =  params.totalPagePdf ? params.totalPagePdf : 0
  return (
    <div>
      <form>
        <p>ListName:{params.listNamePdf}</p>
        <p>ListType:{listTypePdf}</p>
        <p>total Page count {totalPagePdf}</p>
      </form>
    </div>
  )
}

export default Pdf
