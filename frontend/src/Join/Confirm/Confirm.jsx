import React, { useEffect, useState } from 'react'
import { Link, Redirect, useLocation } from 'react-router-dom'
import System from '../../Layout/System'
import { AlertError } from '../../Alert'
import api, { parseError } from '../../Api'

function useQuery() {
  return new URLSearchParams(useLocation().search)
}

function Confirm() {
  const [success, setSuccess] = useState(null)
  const [error, setError] = useState(null)

  const query = useQuery()
  const token = query.get('token')

  useEffect(() => {
    if (token && success === null && error === null) {
      api
        .post('/v1/auth/join/confirm', { token })
        .then(() => setSuccess(true))
        .catch(async (error) => setError(await parseError(error)))
    }
  }, [success, error, token])

  if (success) {
    return <Redirect to="/join/success" push={false} />
  }

  if (!token) {
    return <Redirect to="/" push={false} />
  }

  return (
    <System>
      <div data-testid="join-confirm">
        <h1>Join</h1>
        <AlertError message={error} />
        <p>
          <Link to="/">Back to Home</Link>
        </p>
      </div>
    </System>
  )
}

export default Confirm
