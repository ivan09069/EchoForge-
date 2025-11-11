/**
 * Smoke tests for EchoForge
 * Basic tests to ensure core functionality works
 */

// Test encryption utilities
describe('Encryption utilities', () => {
  // Mock Web Crypto API for Node environment
  beforeAll(() => {
    if (typeof window === 'undefined') {
      global.window = {
        crypto: {
          getRandomValues: (arr) => {
            for (let i = 0; i < arr.length; i++) {
              arr[i] = Math.floor(Math.random() * 256)
            }
            return arr
          },
          subtle: {
            importKey: jest.fn().mockResolvedValue({}),
            deriveKey: jest.fn().mockResolvedValue({}),
            encrypt: jest.fn().mockResolvedValue(new ArrayBuffer(32)),
            decrypt: jest.fn().mockResolvedValue(new TextEncoder().encode('{"test":"data"}').buffer),
          }
        }
      }
    }
  })

  test('encryption module exports required functions', () => {
    const encrypt = require('../lib/encrypt')
    expect(encrypt.encrypt).toBeDefined()
    expect(encrypt.decrypt).toBeDefined()
    expect(encrypt.getEncryptedData).toBeDefined()
    expect(encrypt.setEncryptedData).toBeDefined()
  })
})

// Test IndexedDB utilities
describe('IndexedDB utilities', () => {
  test('idb module exports required functions', () => {
    const idb = require('../lib/idb')
    expect(idb.openDB).toBeDefined()
    expect(idb.getDB).toBeDefined()
    expect(idb.closeDB).toBeDefined()
    expect(idb.setItem).toBeDefined()
    expect(idb.getItem).toBeDefined()
    expect(idb.deleteItem).toBeDefined()
  })
})

// Test WebSocket utilities
describe('WebSocket utilities', () => {
  test('websocket module exports required functions', () => {
    const ws = require('../lib/websocket')
    expect(ws.connectWebSocket).toBeDefined()
    expect(ws.disconnectWebSocket).toBeDefined()
    expect(ws.sendMessage).toBeDefined()
    expect(ws.subscribeToPrices).toBeDefined()
  })
})

// Test React components
describe('React components', () => {
  test('LoginFIDO2 component exists', () => {
    const LoginFIDO2 = require('../components/LoginFIDO2').default
    expect(LoginFIDO2).toBeDefined()
  })

  test('Dashboard component exists', () => {
    const Dashboard = require('../components/Dashboard').default
    expect(Dashboard).toBeDefined()
  })

  test('PriceFeed component exists', () => {
    const PriceFeed = require('../components/PriceFeed').default
    expect(PriceFeed).toBeDefined()
  })
})

// Test pages
describe('Next.js pages', () => {
  test('index page exists', () => {
    const IndexPage = require('../pages/index').default
    expect(IndexPage).toBeDefined()
  })

  test('login page exists', () => {
    const LoginPage = require('../pages/login').default
    expect(LoginPage).toBeDefined()
  })

  test('dashboard page exists', () => {
    const DashboardPage = require('../pages/dashboard').default
    expect(DashboardPage).toBeDefined()
  })
})

// Test configuration files
describe('Configuration', () => {
  test('package.json exists and has required scripts', () => {
    const pkg = require('../package.json')
    expect(pkg.scripts.dev).toBeDefined()
    expect(pkg.scripts.build).toBeDefined()
    expect(pkg.scripts.start).toBeDefined()
    expect(pkg.scripts.test).toBeDefined()
    expect(pkg.scripts.lint).toBeDefined()
  })

  test('next.config.js exists', () => {
    const config = require('../next.config.js')
    expect(config).toBeDefined()
  })

  test('jest.config.js exists', () => {
    const config = require('../jest.config.js')
    expect(config).toBeDefined()
  })
})

// Integration-like tests (without actual rendering)
describe('Application structure', () => {
  test('all required directories exist', () => {
    const fs = require('fs')
    const path = require('path')
    const root = path.join(__dirname, '..')
    
    expect(fs.existsSync(path.join(root, 'pages'))).toBe(true)
    expect(fs.existsSync(path.join(root, 'components'))).toBe(true)
    expect(fs.existsSync(path.join(root, 'lib'))).toBe(true)
    expect(fs.existsSync(path.join(root, 'styles'))).toBe(true)
    expect(fs.existsSync(path.join(root, 'public'))).toBe(true)
  })

  test('required files exist', () => {
    const fs = require('fs')
    const path = require('path')
    const root = path.join(__dirname, '..')
    
    expect(fs.existsSync(path.join(root, 'README.md'))).toBe(true)
    expect(fs.existsSync(path.join(root, 'package.json'))).toBe(true)
    expect(fs.existsSync(path.join(root, 'next.config.js'))).toBe(true)
    expect(fs.existsSync(path.join(root, 'styles/globals.css'))).toBe(true)
    expect(fs.existsSync(path.join(root, 'public/architecture.svg'))).toBe(true)
  })
})

// Basic functionality tests
describe('Basic functionality', () => {
  test('WebSocket connection handler works', () => {
    const { connectWebSocket } = require('../lib/websocket')
    const mockCallback = jest.fn()
    const connection = connectWebSocket('wss://test.com', mockCallback)
    expect(connection).toBeDefined()
  })

  test('IndexedDB open function is defined', () => {
    const { openDB } = require('../lib/idb')
    expect(typeof openDB).toBe('function')
  })
})

// Performance/Smoke tests
describe('Performance checks', () => {
  test('modules load within reasonable time', () => {
    const start = Date.now()
    require('../lib/encrypt')
    require('../lib/idb')
    require('../lib/websocket')
    const end = Date.now()
    
    // Modules should load in less than 100ms
    expect(end - start).toBeLessThan(100)
  })
})
