import React from 'react'
import { createRoot } from 'react-dom/client'
import { Provider } from 'react-redux'
import { PersistGate } from 'redux-persist/integration/react'
import { store, persistor } from './state/store'
import { BrowserRouter } from 'react-router-dom'
//import GlobalNav from './globalNav'
import AppRoutes from './AppRoutes' // ★ 作成したルーティング設定を読み込む

const root = createRoot(document.getElementById('root'))

root.render(
  <Provider store={store}>
    <PersistGate loading={null} persistor={persistor}>
      <BrowserRouter >
        <AppRoutes />
      </BrowserRouter>
    </PersistGate>
  </Provider>
)
