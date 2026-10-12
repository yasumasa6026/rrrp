import React,{ useState, } from 'react'
import { useSelector,useDispatch} from 'react-redux'
import { Routes, Route, useNavigate } from 'react-router-dom'
import AppBar from '@mui/material/AppBar'
import Toolbar from '@mui/material/Toolbar'
import Typography from '@mui/material/Typography'
import Button from '@mui/material/Button'
import { ThemeProvider, createTheme } from '@mui/material/styles'
import { withStyles } from '@mui/styles'
import { LogoutRequest,   } from '../actions'
import Login from './login'
import Signup from './signup'
import ChangePassword from './changepassword'

const GlobalNav = () => {
  // ★ dispatch 関数を取得
  const dispatch = useDispatch()  // ★ 必要な Redux state を直接取得
  const auth = useSelector((state) => state.auth)
  const navigate = useNavigate()
  const changepasswordform = () => { navigate('/changepassword') }
  const loginform = () => { navigate('/login') }
  const signupform = () => { navigate('/signup') }
  const [isLogin,setIsLogin] = useState(true)
  const [isSignUp,setIsSignUp] = useState(false)
  return (
    <div>
      <ThemeProvider theme={theme}>
        <StyledAppBar title='RRRP' position='static' color='primary'>
          <Toolbar position='static'>
            <Typography variant='h5' color={theme.palette.ochre.cntrastText} position='static'>
              RRRP...
            </Typography>
            <Typography variant='h5' gutterBottom>
              {auth.isAuthenticated && <Button
                variant='contained' color='success'
                type='submit' disabled={false}
                onClick={() => { loginform(),  dispatch(LogoutRequest(auth.token, auth.client, auth.uid)) }}
                                  >
                Logout{auth.isSubmitting && <i className='fa fa-spinner fa-spin' />}
                                  </Button>}
            </Typography>
            <Typography variant='h5' gutterBottom>
              {auth.isAuthenticated && <Button
                variant='contained' color='success'
                type='submit' disabled={false} style={{ position: 'absolute', right: 0 }}
              // onClick ={() =>{ChangePasswordFormClick(),changepasswordform()}}>
                onClick={() => { changepasswordform() }}
                                  >
                ChangePassword{auth.isSubmitting && <i className='fa fa-spinner fa-spin' />}
                                  </Button>}
            </Typography>
            <Typography variant='h5' gutterBottom>
              {!auth.isAuthenticated && isLogin && <Button
                variant='contained' color='success'
                type='submit' disabled={false}
                onClick={() => { loginform(), setIsSignUp(true), setIsLogin(false) }}
                                               >
                {auth.isSubmitting && <i className='fa fa-spinner fa-spin' />}Login
                                               </Button>}
            </Typography>
            <Typography variant='h5' gutterBottom>
              {!auth.isAuthenticated && isSignUp && <Button
                variant='contained' color='success'
                type='submit' disabled={false}
                onClick={() => {setIsSignUp(false), setIsLogin(true), signupform() }}
                                              >SignUp
                                              </Button>}
            </Typography>
          </Toolbar>
        </StyledAppBar>
      </ThemeProvider>
    </div>
  )
}

const theme = createTheme({
  palette: {
    ochre: {
      main: '#E3D026', // '#E3D026'
      light: '#E9DB5D',
      dark: '#A29415',
      contrastText: '#242105'
    } // '#242105'
  }
})
const StyledAppBar = withStyles({
  root: {
    // background: 'linear-gradient(45deg, #FE6B8B 30%, #FF8E53 90%)',
    height: 45
  }
})(AppBar)

export default GlobalNav
