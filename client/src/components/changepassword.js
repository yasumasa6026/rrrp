import { useSelector, useDispatch } from 'react-redux'
import { ChangePasswordRequest } from '../actions'
import { useForm } from 'react-hook-form'

const ChangePassword = () => {  
  const auth = useSelector((state) => state.auth)
  const { register, handleSubmit, formState: { errors }, watch } = useForm()  
  // ★ dispatch 関数を取得
  const dispatch = useDispatch()  // ★ 必要な Redux state を直接取得
  const onSubmit = (data) => {
    dispatch(ChangePasswordRequest(data.current_password, data.password, data.password_confirmation))
  }
  return (
    <div>
      <form onSubmit={handleSubmit(onSubmit)}>
        <h1>ChangePassword</h1>
        <ul>
          <li>
            <label htmlFor='email'>
              email:
            </label>
            <input
              type='email' placeholder='email' {...register(
                'email',
                {
                  required: true,
                  message: 'this is required',
                  validate: (value) => { if (value !== auth.uid) return 'email does not match.' }
                })}
            />
          </li>
          <li>
            <label htmlFor='password'>
              current_password:
            </label>
            <input
              type='password' name='current_password' {...register(
                'current_password',
                {
                  required: true,
                  message: 'this is required',
                  validate: (value) => { if (value !== auth.password) return 'current password does not match.' }
                })}
            />
          </li>
          <li>
            <label htmlFor='password'>
              new-password:
            </label>
            <input
              type='password' {...register(
                'password',
                { required: true, minLength: { value: 8, message: 'Password must be at least 8 characters long' } })}
            />
          </li>
          <li>
            <label htmlFor='password_confirmation'>
              password_confirmation:
            </label>
            <input
              type='password'
              {...register(
                'password_confirmation',
                { validate: (value) => { if (value !== watch('password')) return "New Passwords don't match." } })}
            />
          </li>
        </ul>
        <button type='submit' disabled={auth.isSubmitting}>
          Submit
        </button>
      </form>
      <div style={{ color: 'red' }}>
        {errors.email ? `There are errors, check your console. ${errors.email.message}` : null}
        {errors.current_password ? `${errors.current_password.message}` : null}
        {errors.password ? `${errors.password.message}` : null}
        {errors.password_confirmation ? `${errors.password_confirmation.message}` : null}
        {auth.result === 'ok' ? ' ok ' : null}
      </div>
    </div>
  )
}


export default ChangePassword
