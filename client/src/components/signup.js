import React from 'react'
import {  useSelector, useDispatch } from 'react-redux'
import { SignUpRequest } from '../actions'
import { useForm } from 'react-hook-form'

// LOGIN FORM
// @NOTE For forms that can be reused for both create/update you would move this form to its own
// file and import it with different initialValues depending on the use-case. An over-optimization
// for this simple signup form however.
const SignUp = () => {
  // ★ dispatch 関数を取得
  const auth = useSelector((state) => state.auth)
  const { register, handleSubmit, formState: { errors }, watch } = useForm()
  const dispatch = useDispatch()  // ★ 必要な Redux state を直接取得
  const onSubmit = (data) => {
                            dispatch(SignUpRequest(data.email, data.password, data.password_confirmation))
                      }
  return (
    <div>
      <form onSubmit={handleSubmit(onSubmit)}>
        <h1>SignUp</h1>
        <ul>
          <li>
            <label htmlFor='email'>
              email:
            </label>
            <input
              type='email' placeholder='mail' {...register(
                'email',
                {
                  required: 'this is required',
                  pattern: {
                    value: /^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$/,
                    message: 'Invalid email address'
                  }
                })}
            />
            {errors.email && errors.email.message}
          </li>
          <li>
            <label htmlFor='password'>
              password:
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
                { validate: (value) => value === watch('password') || "Passwords don't match." })}
            />
          </li>
        </ul>
        <button type='submit' disabled={auth.isSubmitting}>
          Submit
        </button>
      </form>
      <div style={{ color: 'red' }}>
        {errors.password &&
            ` password error.${errors.password.message}`}
        {errors.password_confirmation &&
            ` password confirmation does not match.${errors.password_confirmation.message}`}
        {auth.result}
      </div>
    </div>
  )
}

export default SignUp
