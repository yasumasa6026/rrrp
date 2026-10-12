//上部に GlobalNav を表示し、その下（<Outlet />）に現在の URL に応じた画面コンポーネントを差し込む枠組み
import React from 'react'
import { Outlet } from 'react-router-dom'
import GlobalNav from './globalNav'
const Layout = () => {
  return (
    <div>
      {/* 常に表示される共通ヘッダー */}
      <GlobalNav />
      {/* URLに応じて各画面（Login, Menus7など）がここに表示される */}
      <main style={{ padding: '16px' }}>
        <Outlet />
      </main>
    </div>
    )
}
export default Layout