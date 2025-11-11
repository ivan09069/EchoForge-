/**
 * WebSocket utilities for real-time price feeds
 */

let activeConnections = new Map()

/**
 * Connect to WebSocket server
 * @param {string} url - WebSocket URL
 * @param {Function} onMessage - Message handler callback
 * @param {Object} options - Connection options
 * @returns {WebSocket|null}
 */
export function connectWebSocket(url, onMessage, options = {}) {
  const {
    onOpen = null,
    onClose = null,
    onError = null,
    reconnect = true,
    reconnectDelay = 3000,
    maxReconnectAttempts = 5
  } = options

  // Check if WebSocket is supported
  if (typeof WebSocket === 'undefined') {
    console.error('WebSocket is not supported in this environment')
    return null
  }

  // In browser environment, we'll simulate the connection
  // since we don't have a real WebSocket server
  if (typeof window !== 'undefined') {
    console.log(`Simulating WebSocket connection to: ${url}`)
    
    // Create a mock WebSocket object for demo purposes
    const mockWS = {
      url: url,
      readyState: 1, // OPEN
      send: (data) => {
        console.log('Mock WebSocket send:', data)
      },
      close: () => {
        console.log('Mock WebSocket closed')
        if (onClose) onClose()
      }
    }
    
    // Store connection
    activeConnections.set(url, mockWS)
    
    // Simulate connection opened
    if (onOpen) {
      setTimeout(() => onOpen(), 100)
    }
    
    return mockWS
  }

  // Real WebSocket implementation (for server-side or production)
  let ws = null
  let reconnectAttempts = 0

  const connect = () => {
    try {
      ws = new WebSocket(url)
      
      ws.onopen = (event) => {
        console.log('WebSocket connected:', url)
        reconnectAttempts = 0
        if (onOpen) onOpen(event)
      }
      
      ws.onmessage = (event) => {
        try {
          const data = JSON.parse(event.data)
          onMessage(data)
        } catch (error) {
          console.error('Failed to parse WebSocket message:', error)
          onMessage(event.data)
        }
      }
      
      ws.onerror = (event) => {
        console.error('WebSocket error:', event)
        if (onError) onError(event)
      }
      
      ws.onclose = (event) => {
        console.log('WebSocket closed:', event.code, event.reason)
        activeConnections.delete(url)
        
        if (onClose) onClose(event)
        
        // Attempt reconnection if enabled
        if (reconnect && reconnectAttempts < maxReconnectAttempts) {
          reconnectAttempts++
          console.log(`Reconnecting... (attempt ${reconnectAttempts}/${maxReconnectAttempts})`)
          setTimeout(connect, reconnectDelay)
        }
      }
      
      // Store connection
      activeConnections.set(url, ws)
      
    } catch (error) {
      console.error('Failed to create WebSocket connection:', error)
      if (onError) onError(error)
    }
  }

  connect()
  return ws
}

/**
 * Disconnect WebSocket
 * @param {WebSocket} ws - WebSocket instance
 */
export function disconnectWebSocket(ws) {
  if (!ws) return
  
  try {
    if (ws.readyState === WebSocket.OPEN || ws.readyState === WebSocket.CONNECTING) {
      ws.close(1000, 'Client disconnecting')
    }
  } catch (error) {
    console.error('Error disconnecting WebSocket:', error)
  }
}

/**
 * Send message through WebSocket
 * @param {WebSocket} ws - WebSocket instance
 * @param {any} data - Data to send
 * @returns {boolean} Success status
 */
export function sendMessage(ws, data) {
  if (!ws) {
    console.error('WebSocket is not connected')
    return false
  }
  
  try {
    if (ws.readyState === WebSocket.OPEN) {
      const message = typeof data === 'string' ? data : JSON.stringify(data)
      ws.send(message)
      return true
    } else {
      console.error('WebSocket is not open')
      return false
    }
  } catch (error) {
    console.error('Failed to send message:', error)
    return false
  }
}

/**
 * Close all active WebSocket connections
 */
export function disconnectAll() {
  activeConnections.forEach((ws, url) => {
    console.log('Closing connection to:', url)
    disconnectWebSocket(ws)
  })
  activeConnections.clear()
}

/**
 * Get active connections count
 * @returns {number}
 */
export function getActiveConnectionsCount() {
  return activeConnections.size
}

/**
 * Check if connected to specific URL
 * @param {string} url - WebSocket URL
 * @returns {boolean}
 */
export function isConnected(url) {
  const ws = activeConnections.get(url)
  return ws && ws.readyState === WebSocket.OPEN
}

/**
 * Subscribe to price updates (demo implementation)
 * @param {string[]} symbols - Array of symbols to subscribe to
 * @param {Function} callback - Price update callback
 * @returns {WebSocket|null}
 */
export function subscribeToPrices(symbols, callback) {
  const url = 'wss://demo.echoforge.app/prices'
  
  const ws = connectWebSocket(url, (data) => {
    callback(data)
  }, {
    onOpen: () => {
      // Subscribe to symbols on connection
      sendMessage(ws, {
        type: 'subscribe',
        symbols: symbols
      })
    }
  })
  
  return ws
}

/**
 * Unsubscribe from price updates
 * @param {WebSocket} ws - WebSocket instance
 * @param {string[]} symbols - Array of symbols to unsubscribe from
 */
export function unsubscribeFromPrices(ws, symbols) {
  if (!ws) return
  
  sendMessage(ws, {
    type: 'unsubscribe',
    symbols: symbols
  })
}
