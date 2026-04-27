import { connect } from 'react-redux'

const Pdf = ({listNamePdf,listTypePdf,totalPagePdf,}) => {
            
          
        return(                 
        <div>
        <form  > 
           <p>ListName:{listNamePdf}</p>
           <p>ListType:{listTypePdf}</p>
           <p>total Page count {totalPagePdf}</p>
        </form> 
        </div> 
        )             
}
  
    const mapStateToProps = (state,ownProps)  =>({  
      listNamePdf:state.screen.params.listNamePdf,
      listTypePdf:state.screen.params.listTypePdf?state.screen.params.listTypePdf:"",
      totalPagePdf:state.screen.params.totalPagePdf?state.screen.params.totalPagePdf:0,
    })
    
    const mapDispatchToProps = () => ({
    })
    
export  default  connect(mapStateToProps,mapDispatchToProps)(Pdf)