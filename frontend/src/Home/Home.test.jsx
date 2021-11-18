import React from 'react'
import { render } from '@testing-library/react'
import Home from './Home'

test('renders home', () => {
  const { getByText } = render(<Home />)
  const h1Element = getByText(/Auction/i)
  expect(h1Element).toBeInTheDocument()
})
