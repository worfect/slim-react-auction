import React from 'react'
import './App.css'
import { BrowserRouter, Route, Routes } from 'react-router-dom'
import Home from '../Home'
import Join from '../Join'
import { NotFound } from '../Error'
import Confirm from '../Join/Confirm'
import Success from '../Join/Success'
import OAuth from '../OAuth'
import { AuthProvider } from '../OAuth/Provider'
function App() {
  return (
    <AuthProvider
      authorizeUrl={process.env.REACT_APP_AUTH_URL + '/authorize'}
      tokenUrl={process.env.REACT_APP_AUTH_URL + '/token'}
      clientId="frontend"
      scope="common"
      redirectPath="/oauth"
    >
      <BrowserRouter>
        <div className="app">
          <Routes>
            <Route exact path="/" element={<Home />} />
            <Route exact path="/oauth" element={<OAuth />} />
            <Route exact path="/join" element={<Join />} />
            <Route exact path="/join/confirm" element={<Confirm />} />
            <Route exact path="/join/success" element={<Success />} />
            <Route path="*" element={<NotFound />} />
          </Routes>
        </div>
      </BrowserRouter>
    </AuthProvider>
  )
}

export default App
