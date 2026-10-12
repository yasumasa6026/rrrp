//ログインしているか判定し、未ログインなら自動的に /login へ転送する共通部品
import React from 'react'
import { Navigate } from 'react-router-dom'
import { useSelector } from 'react-redux'
const ProtectedRoute = ({ children }) => {
  const isAuthenticated = useSelector((state) => state.auth.isAuthenticated)
  if (!isAuthenticated) {
    // 未認証の場合はログイン画面へリダイレクト
    return <Navigate to="/login" replace />
  }
  // 認証済みの場合はそのまま子要素（指定された画面）を表示
  return children
}
export default ProtectedRoute