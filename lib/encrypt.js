/**
 * Encryption utilities using Web Crypto API
 * Implements AES-GCM encryption for secure local storage
 */

const ALGORITHM = 'AES-GCM'
const KEY_LENGTH = 256
const IV_LENGTH = 12

/**
 * Generate a cryptographic key from a password
 * @param {string} password - User password or passphrase
 * @returns {Promise<CryptoKey>}
 */
async function deriveKey(password) {
  const encoder = new TextEncoder()
  const passwordBuffer = encoder.encode(password)
  
  // Import password as key material
  const keyMaterial = await window.crypto.subtle.importKey(
    'raw',
    passwordBuffer,
    'PBKDF2',
    false,
    ['deriveBits', 'deriveKey']
  )
  
  // Derive AES key using PBKDF2
  const salt = new Uint8Array([
    // In production, use a unique salt per user stored separately
    0x4e, 0x61, 0x43, 0x6c, 0x53, 0x61, 0x6c, 0x74,
    0x45, 0x63, 0x68, 0x6f, 0x46, 0x6f, 0x72, 0x67
  ])
  
  return await window.crypto.subtle.deriveKey(
    {
      name: 'PBKDF2',
      salt: salt,
      iterations: 100000,
      hash: 'SHA-256'
    },
    keyMaterial,
    { name: ALGORITHM, length: KEY_LENGTH },
    false,
    ['encrypt', 'decrypt']
  )
}

/**
 * Encrypt data using AES-GCM
 * @param {any} data - Data to encrypt
 * @param {string} password - Encryption password
 * @returns {Promise<{encrypted: ArrayBuffer, iv: Uint8Array}>}
 */
export async function encrypt(data, password = 'default-key') {
  try {
    const key = await deriveKey(password)
    const encoder = new TextEncoder()
    const dataString = JSON.stringify(data)
    const dataBuffer = encoder.encode(dataString)
    
    // Generate random IV
    const iv = window.crypto.getRandomValues(new Uint8Array(IV_LENGTH))
    
    // Encrypt
    const encrypted = await window.crypto.subtle.encrypt(
      {
        name: ALGORITHM,
        iv: iv
      },
      key,
      dataBuffer
    )
    
    return { encrypted, iv }
  } catch (error) {
    console.error('Encryption failed:', error)
    throw new Error('Failed to encrypt data')
  }
}

/**
 * Decrypt data using AES-GCM
 * @param {ArrayBuffer} encryptedData - Encrypted data
 * @param {Uint8Array} iv - Initialization vector
 * @param {string} password - Decryption password
 * @returns {Promise<any>}
 */
export async function decrypt(encryptedData, iv, password = 'default-key') {
  try {
    const key = await deriveKey(password)
    
    // Decrypt
    const decrypted = await window.crypto.subtle.decrypt(
      {
        name: ALGORITHM,
        iv: iv
      },
      key,
      encryptedData
    )
    
    // Convert back to original data
    const decoder = new TextDecoder()
    const dataString = decoder.decode(decrypted)
    return JSON.parse(dataString)
  } catch (error) {
    console.error('Decryption failed:', error)
    throw new Error('Failed to decrypt data')
  }
}

/**
 * Get encrypted data from IndexedDB
 * @param {IDBDatabase} db - IndexedDB database
 * @param {string} key - Storage key
 * @returns {Promise<any>}
 */
export async function getEncryptedData(db, key) {
  try {
    const tx = db.transaction('encrypted', 'readonly')
    const store = tx.objectStore('encrypted')
    const result = await store.get(key)
    
    if (!result) {
      return null
    }
    
    return await decrypt(result.data, result.iv)
  } catch (error) {
    console.error('Failed to get encrypted data:', error)
    return null
  }
}

/**
 * Set encrypted data in IndexedDB
 * @param {IDBDatabase} db - IndexedDB database
 * @param {string} key - Storage key
 * @param {any} data - Data to encrypt and store
 * @returns {Promise<void>}
 */
export async function setEncryptedData(db, key, data) {
  try {
    const { encrypted, iv } = await encrypt(data)
    
    const tx = db.transaction('encrypted', 'readwrite')
    const store = tx.objectStore('encrypted')
    await store.put({
      key: key,
      data: encrypted,
      iv: iv,
      timestamp: Date.now()
    }, key)
    
    await tx.complete
  } catch (error) {
    console.error('Failed to set encrypted data:', error)
    throw error
  }
}

/**
 * Delete encrypted data from IndexedDB
 * @param {IDBDatabase} db - IndexedDB database
 * @param {string} key - Storage key
 * @returns {Promise<void>}
 */
export async function deleteEncryptedData(db, key) {
  try {
    const tx = db.transaction('encrypted', 'readwrite')
    const store = tx.objectStore('encrypted')
    await new Promise((resolve, reject) => {
      const request = store.delete(key)
      request.onsuccess = () => resolve()
      request.onerror = () => reject(request.error)
    })
    await tx.complete
  } catch (error) {
    console.error('Failed to delete encrypted data:', error)
    throw error
  }
}
