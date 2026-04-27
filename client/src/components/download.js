import React from 'react'
import { connect } from 'react-redux'

const Download = ({screenName,filtered,totalCount,}) => {
            
          
        return(                 
        <div>
        <form  > 
           <p>DownLoad ScreenName:{screenName}</p>
           <p>select condition </p>
           {filtered.length===0?<p>all data selected </p>: filtered.map((val,idx) =>{
                                                    return <p key={idx}>{JSON.parse(val).id} : {JSON.parse(val).value}</p>
           })}
           <p>total record count {totalCount}</p>
        </form> 
        </div> 
        )             
}
  
    const mapStateToProps = (state,ownProps)  =>({  
      button:state.button,
      screenCode:state.screen.params.screenCode,
      screenName:state.screen.params.screenName,
      filtered:state.screen.params.filtered?state.screen.params.filtered:[], 
      totalCount:state.button.totalCount,
    })
    
    const mapDispatchToProps = () => ({
    })
    
export  default  connect(mapStateToProps,mapDispatchToProps)(Download)