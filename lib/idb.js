/**
 * IndexedDB wrapper for encrypted local storage
 */

const DB_NAME = 'echoforge-db'
const DB_VERSION = 1

let dbInstance = null

/**
 * Open or create IndexedDB database
 * @returns {Promise<IDBDatabase>}
 */
export async function openDB() {
  return new Promise((resolve, reject) => {
    const request = indexedDB.open(DB_NAME, DB_VERSION)
    
    request.onerror = () => {
      reject(new Error('Failed to open database'))
    }
    
    request.onsuccess = () => {
      resolve(request.result)
    }
    
    request.onupgradeneeded = (event) => {
      const db = event.target.result
      
      // Create object stores
      if (!db.objectStoreNames.contains('encrypted')) {
        db.createObjectStore('encrypted', { keyPath: 'key' })
      }
      
      if (!db.objectStoreNames.contains('metadata')) {
        db.createObjectStore('metadata', { keyPath: 'key' })
      }
      
      if (!db.objectStoreNames.contains('cache')) {
        const cacheStore = db.createObjectStore('cache', { keyPath: 'key' })
        cacheStore.createIndex('timestamp', 'timestamp', { unique: false })
      }
    }
  })
}

/**
 * Get database instance (singleton pattern)
 * @returns {Promise<IDBDatabase>}
 */
export async function getDB() {
  if (!dbInstance) {
    dbInstance = await openDB()
  }
  return dbInstance
}

/**
 * Close database connection
 */
export function closeDB() {
  if (dbInstance) {
    dbInstance.close()
    dbInstance = null
  }
}

/**
 * Store data in object store
 * @param {string} storeName - Object store name
 * @param {string} key - Storage key
 * @param {any} value - Value to store
 * @returns {Promise<void>}
 */
export async function setItem(storeName, key, value) {
  const db = await getDB()
  
  return new Promise((resolve, reject) => {
    const tx = db.transaction(storeName, 'readwrite')
    const store = tx.objectStore(storeName)
    
    const data = {
      key: key,
      value: value,
      timestamp: Date.now()
    }
    
    const request = store.put(data)
    
    request.onsuccess = () => resolve()
    request.onerror = () => reject(new Error('Failed to store data'))
  })
}

/**
 * Get data from object store
 * @param {string} storeName - Object store name
 * @param {string} key - Storage key
 * @returns {Promise<any>}
 */
export async function getItem(storeName, key) {
  const db = await getDB()
  
  return new Promise((resolve, reject) => {
    const tx = db.transaction(storeName, 'readonly')
    const store = tx.objectStore(storeName)
    const request = store.get(key)
    
    request.onsuccess = () => {
      const result = request.result
      resolve(result ? result.value : null)
    }
    request.onerror = () => reject(new Error('Failed to get data'))
  })
}

/**
 * Delete data from object store
 * @param {string} storeName - Object store name
 * @param {string} key - Storage key
 * @returns {Promise<void>}
 */
export async function deleteItem(storeName, key) {
  const db = await getDB()
  
  return new Promise((resolve, reject) => {
    const tx = db.transaction(storeName, 'readwrite')
    const store = tx.objectStore(storeName)
    const request = store.delete(key)
    
    request.onsuccess = () => resolve()
    request.onerror = () => reject(new Error('Failed to delete data'))
  })
}

/**
 * Get all keys from object store
 * @param {string} storeName - Object store name
 * @returns {Promise<string[]>}
 */
export async function getAllKeys(storeName) {
  const db = await getDB()
  
  return new Promise((resolve, reject) => {
    const tx = db.transaction(storeName, 'readonly')
    const store = tx.objectStore(storeName)
    const request = store.getAllKeys()
    
    request.onsuccess = () => resolve(request.result)
    request.onerror = () => reject(new Error('Failed to get keys'))
  })
}

/**
 * Clear all data from object store
 * @param {string} storeName - Object store name
 * @returns {Promise<void>}
 */
export async function clearStore(storeName) {
  const db = await getDB()
  
  return new Promise((resolve, reject) => {
    const tx = db.transaction(storeName, 'readwrite')
    const store = tx.objectStore(storeName)
    const request = store.clear()
    
    request.onsuccess = () => resolve()
    request.onerror = () => reject(new Error('Failed to clear store'))
  })
}

/**
 * Clear expired cache entries
 * @param {number} maxAge - Maximum age in milliseconds
 * @returns {Promise<number>} Number of deleted entries
 */
export async function clearExpiredCache(maxAge = 24 * 60 * 60 * 1000) {
  const db = await getDB()
  const cutoffTime = Date.now() - maxAge
  
  return new Promise((resolve, reject) => {
    const tx = db.transaction('cache', 'readwrite')
    const store = tx.objectStore('cache')
    const index = store.index('timestamp')
    const request = index.openCursor(IDBKeyRange.upperBound(cutoffTime))
    
    let deleteCount = 0
    
    request.onsuccess = (event) => {
      const cursor = event.target.result
      if (cursor) {
        cursor.delete()
        deleteCount++
        cursor.continue()
      } else {
        resolve(deleteCount)
      }
    }
    
    request.onerror = () => reject(new Error('Failed to clear cache'))
  })
}
