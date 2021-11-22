import React, { useState } from 'react'
import styles from './JoinForm.module.css'
import api, { parseError, parseErrors } from '../../Api'
import { AlertError, AlertSuccess } from '../../Alert'
import { InputError } from '../../Form'

function JoinForm() {
  const [formData, setFormData] = useState({
    email: '',
    password: '',
    agree: false,
  })

  const [buttonActive, setButtonActive] = useState(true)
  const [errors, setErrors] = useState({})
  const [error, setError] = useState(null)
  const [success, setSuccess] = useState(null)

  const handleChange = (event) => {
    const input = event.target
    setFormData({
      ...formData,
      [input.name]: input.type === 'checkbox' ? input.checked : input.value,
    })
  }

  const handleSubmit = (event) => {
    event.preventDefault()

    if (!formData.agree) {
      setErrors({ agree: 'Please agree with terms.' })
      return
    }

    setButtonActive(false)
    setErrors({})
    setError(null)
    setSuccess(null)

    api
      .post('/v1/auth/join', {
        email: formData.email,
        password: formData.password,
      })
      .then(() => {
        setSuccess('Confirm join by link in email.')
        setButtonActive(true)
      })
      .catch(async (error) => {
        setErrors(await parseErrors(error))
        setError(await parseError(error))
        setButtonActive(true)
      })
  }

  return (
    <div data-testid="join-form" className={styles.joinForm}>
      <AlertError message={error} />
      <AlertSuccess message={success} />

      {!success ? (
        <form className="form" method="post" onSubmit={handleSubmit}>
          <div className={'input-row' + (errors.email ? ' has-error' : '')}>
            <label htmlFor="email" className="input-label">
              Email
            </label>
            <input
              id="email"
              name="email"
              type="email"
              value={formData.email}
              onChange={handleChange}
              required
            />
            <InputError error={errors.email} />
          </div>
          <div className={'input-row' + (errors.password ? ' has-error' : '')}>
            <label htmlFor="password" className="input-label">
              Password
            </label>
            <input
              id="password"
              name="password"
              type="password"
              value={formData.password}
              onChange={handleChange}
              required
            />
            <InputError error={errors.password} />
          </div>
          <div className={'input-row' + (errors.agree ? ' has-error' : '')}>
            <label>
              <input
                name="agree"
                type="checkbox"
                checked={formData.agree}
                onChange={handleChange}
                required
              />
              <small>I agree with privacy policy</small>
            </label>
            <InputError error={errors.agree} />
          </div>
          <div className="button-row">
            <button
              type="submit"
              data-testid="join-button"
              disabled={!buttonActive}
            >
              Join to Us
            </button>
          </div>
        </form>
      ) : null}
    </div>
  )
}

export default JoinForm
