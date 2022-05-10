import React from 'react'
import { render } from '@testing-library/react'
import Home from './Home'
import { MemoryRouter } from 'react-router-dom'

test('renders home', () => {
  render(
      <MemoryRouter>
        <Home />
      </MemoryRouter>
  )
})
