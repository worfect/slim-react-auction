import React from 'react'
import './App.css'
import Home from '../Home'
import { NotFound } from '../Error'
import Join from '../Join'
import Confirm from '../Join/Confirm'
import Success from '../Join/Success'

import { BrowserRouter, Route, Switch } from 'react-router-dom'

function App() {
  return (
    <BrowserRouter>
      <div className="app">
        <Switch>
          <Route exact path="/">
            <Home />
          </Route>
          <Route exact path="/join">
            <Join />
          </Route>
          <Route exact path="/join/confirm">
            <Confirm />
          </Route>
          <Route exact path="/join/success">
            <Success />
          </Route>
          <Route path="*">
            <NotFound />
          </Route>
        </Switch>
      </div>
    </BrowserRouter>
  )
}

export default App
