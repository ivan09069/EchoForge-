import Head from 'next/head'
import Link from 'next/link'
import { useEffect, useState } from 'react'
import Dashboard from '../components/Dashboard'
import PriceFeed from '../components/PriceFeed'
import { getEncryptedData, setEncryptedData } from '../lib/encrypt'
import { getDB } from '../lib/idb'

export default function DashboardPage() {
  const [isAuthenticated, setIsAuthenticated] = useState(false)
  const [portfolioData, setPortfolioData] = useState(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    // Check authentication status
    const checkAuth = async () => {
      try {
        // In a real app, verify session/token
        const authStatus = sessionStorage.getItem('authenticated')
        setIsAuthenticated(!!authStatus)
        
        if (authStatus) {
          // Load encrypted portfolio data
          const db = await getDB()
          const data = await getEncryptedData(db, 'portfolio')
          setPortfolioData(data || { assets: [], totalValue: 0 })
        }
      } catch (error) {
        console.error('Auth check failed', error)
      } finally {
        setLoading(false)
      }
    }

    checkAuth()
  }, [])

  const handleDataUpdate = async (newData) => {
    try {
      const db = await getDB()
      await setEncryptedData(db, 'portfolio', newData)
      setPortfolioData(newData)
    } catch (error) {
      console.error('Failed to save data', error)
    }
  }

  if (loading) {
    return (
      <div className="container">
        <main className="main">
          <p>Loading...</p>
        </main>
      </div>
    )
  }

  if (!isAuthenticated) {
    return (
      <div className="container">
        <Head>
          <title>Dashboard - EchoForge</title>
        </Head>
        <main className="main">
          <h1>Access Denied</h1>
          <p>Please <Link href="/login">login</Link> to view your dashboard.</p>
        </main>
      </div>
    )
  }

  return (
    <div className="container">
      <Head>
        <title>Dashboard - EchoForge</title>
        <meta name="description" content="Your secure portfolio dashboard" />
      </Head>

      <main className="main">
        <h1 className="title">
          Your <span className="brand">Portfolio</span>
        </h1>

        <Dashboard 
          portfolioData={portfolioData}
          onDataUpdate={handleDataUpdate}
        />

        <div className="price-feed-section">
          <h2>Live Price Feed</h2>
          <PriceFeed />
        </div>
      </main>
    </div>
  )
}
