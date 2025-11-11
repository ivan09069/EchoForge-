import { useEffect, useState } from 'react'
import { connectWebSocket, disconnectWebSocket } from '../lib/websocket'

export default function PriceFeed() {
  const [prices, setPrices] = useState({})
  const [connected, setConnected] = useState(false)
  const [lastUpdate, setLastUpdate] = useState(null)

  useEffect(() => {
    // Simulate price feed updates
    // In production, this would connect to a real WebSocket service
    const symbols = ['BTC', 'ETH', 'SOL', 'ADA', 'DOT']
    
    // Initialize with random prices
    const initialPrices = {}
    symbols.forEach(symbol => {
      initialPrices[symbol] = getRandomPrice(symbol)
    })
    setPrices(initialPrices)
    setConnected(true)

    // Simulate WebSocket connection
    const ws = connectWebSocket('wss://demo.echoforge.app/prices', (data) => {
      // This would handle real WebSocket messages
      console.log('Price update:', data)
    })

    // Update prices periodically
    const interval = setInterval(() => {
      const updatedPrices = { ...initialPrices }
      symbols.forEach(symbol => {
        // Simulate price fluctuation (±2%)
        const currentPrice = updatedPrices[symbol] || getRandomPrice(symbol)
        const change = currentPrice * (Math.random() * 0.04 - 0.02)
        updatedPrices[symbol] = Math.max(0.01, currentPrice + change)
      })
      setPrices(updatedPrices)
      setLastUpdate(new Date())
    }, 3000) // Update every 3 seconds

    return () => {
      clearInterval(interval)
      disconnectWebSocket(ws)
    }
  }, [])

  const getRandomPrice = (symbol) => {
    const basePrices = {
      BTC: 45000,
      ETH: 3000,
      SOL: 100,
      ADA: 0.50,
      DOT: 7.5,
    }
    return basePrices[symbol] || 100
  }

  const formatPrice = (price) => {
    if (!price) return '$0.00'
    if (price < 1) return `$${price.toFixed(4)}`
    if (price < 100) return `$${price.toFixed(2)}`
    return `$${price.toFixed(2).replace(/\B(?=(\d{3})+(?!\d))/g, ',')}`
  }

  return (
    <div className="price-feed">
      <div className="feed-header">
        <div className="connection-status">
          <span className={`status-indicator ${connected ? 'connected' : 'disconnected'}`}></span>
          <span>{connected ? 'Live' : 'Disconnected'}</span>
        </div>
        {lastUpdate && (
          <div className="last-update">
            Last update: {lastUpdate.toLocaleTimeString()}
          </div>
        )}
      </div>

      <div className="price-cards">
        {Object.entries(prices).map(([symbol, price]) => (
          <div key={symbol} className="price-card">
            <div className="symbol">{symbol}</div>
            <div className="price">{formatPrice(price)}</div>
            <div className="change">
              <span className="change-indicator">●</span> Live
            </div>
          </div>
        ))}
      </div>

      <div className="feed-info">
        <p>
          <strong>Demo Mode:</strong> Prices are simulated. In production, 
          this would connect to real-time cryptocurrency price APIs.
        </p>
      </div>
    </div>
  )
}
