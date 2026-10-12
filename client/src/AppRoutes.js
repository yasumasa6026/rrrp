
import React from 'react'
import { Routes, Route, Navigate } from 'react-router-dom'
// 各画面のインポート
import Layout from './components/Layout'
import ProtectedRoute from './components/ProtectedRoute'
import Login from './components/login'
import Signup from './components/signup'
import ChangePassword from './components/changepassword'
import Menus7 from './components/menus7'
const NotFound = () => <h2>404 - ページが見つかりません</h2>
const AppRoutes = () => {
  return (
    <Routes>
      {/* 共通レイアウト（Layout）の配下に全画面を定義 */}
      <Route element={<Layout />}>
        {/* ルートURL '/' にアクセスしたときのリダイレクト */}
        <Route path="/" element={<Navigate to="/login" replace />} />
        {/* --- パブリックルート（誰でもアクセス可能） --- */}
        <Route path="/login" element={<Login />} />
        <Route path="/signup" element={<Signup />} />
        {/* --- 保護されたルート（ログイン必須） --- */}
        <Route
          path="/menus7"
          element={
            <ProtectedRoute>
              <Menus7 screenFlg="first" />
            </ProtectedRoute>
          }
        />
        <Route
          path="/changepassword"
          element={
            <ProtectedRoute>
              <ChangePassword />
            </ProtectedRoute>
          }
        />
        {/* --- 存在しない URL にアクセスされた場合（404） --- */}
        <Route path="*" element={<NotFound />} />
      </Route>
    </Routes>
  )
}
export default AppRoutes
