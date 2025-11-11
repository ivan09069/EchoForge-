import { useState } from 'react'

export default function Dashboard({ portfolioData, onDataUpdate }) {
  const [isEditing, setIsEditing] = useState(false)
  const [newAsset, setNewAsset] = useState({ symbol: '', amount: '', purchasePrice: '' })

  const handleAddAsset = () => {
    if (!newAsset.symbol || !newAsset.amount) {
      alert('Please fill in all fields')
      return
    }

    const updatedData = {
      ...portfolioData,
      assets: [
        ...(portfolioData?.assets || []),
        {
          id: Date.now(),
          symbol: newAsset.symbol.toUpperCase(),
          amount: parseFloat(newAsset.amount),
          purchasePrice: parseFloat(newAsset.purchasePrice) || 0,
          currentPrice: 0, // Will be updated by price feed
        },
      ],
    }

    onDataUpdate(updatedData)
    setNewAsset({ symbol: '', amount: '', purchasePrice: '' })
    setIsEditing(false)
  }

  const handleRemoveAsset = (assetId) => {
    const updatedData = {
      ...portfolioData,
      assets: portfolioData.assets.filter(asset => asset.id !== assetId),
    }
    onDataUpdate(updatedData)
  }

  const calculateTotalValue = () => {
    if (!portfolioData?.assets) return 0
    return portfolioData.assets.reduce((total, asset) => {
      return total + (asset.amount * asset.currentPrice)
    }, 0)
  }

  const calculateTotalCost = () => {
    if (!portfolioData?.assets) return 0
    return portfolioData.assets.reduce((total, asset) => {
      return total + (asset.amount * asset.purchasePrice)
    }, 0)
  }

  const calculateProfitLoss = () => {
    const totalValue = calculateTotalValue()
    const totalCost = calculateTotalCost()
    return totalValue - totalCost
  }

  return (
    <div className="dashboard">
      <div className="portfolio-summary">
        <div className="summary-card">
          <h3>Total Value</h3>
          <p className="value">${calculateTotalValue().toFixed(2)}</p>
        </div>
        <div className="summary-card">
          <h3>Total Cost</h3>
          <p className="value">${calculateTotalCost().toFixed(2)}</p>
        </div>
        <div className="summary-card">
          <h3>Profit/Loss</h3>
          <p className={`value ${calculateProfitLoss() >= 0 ? 'positive' : 'negative'}`}>
            ${calculateProfitLoss().toFixed(2)}
          </p>
        </div>
      </div>

      <div className="assets-section">
        <div className="section-header">
          <h2>Your Assets</h2>
          <button 
            onClick={() => setIsEditing(!isEditing)}
            className="button secondary"
          >
            {isEditing ? 'Cancel' : '+ Add Asset'}
          </button>
        </div>

        {isEditing && (
          <div className="add-asset-form">
            <input
              type="text"
              placeholder="Symbol (e.g., BTC, ETH)"
              value={newAsset.symbol}
              onChange={(e) => setNewAsset({ ...newAsset, symbol: e.target.value })}
            />
            <input
              type="number"
              placeholder="Amount"
              step="0.00000001"
              value={newAsset.amount}
              onChange={(e) => setNewAsset({ ...newAsset, amount: e.target.value })}
            />
            <input
              type="number"
              placeholder="Purchase Price"
              step="0.01"
              value={newAsset.purchasePrice}
              onChange={(e) => setNewAsset({ ...newAsset, purchasePrice: e.target.value })}
            />
            <button onClick={handleAddAsset} className="button primary">
              Add
            </button>
          </div>
        )}

        <div className="assets-list">
          {portfolioData?.assets && portfolioData.assets.length > 0 ? (
            <table className="assets-table">
              <thead>
                <tr>
                  <th>Symbol</th>
                  <th>Amount</th>
                  <th>Purchase Price</th>
                  <th>Current Price</th>
                  <th>Value</th>
                  <th>P/L</th>
                  <th>Actions</th>
                </tr>
              </thead>
              <tbody>
                {portfolioData.assets.map((asset) => {
                  const value = asset.amount * asset.currentPrice
                  const cost = asset.amount * asset.purchasePrice
                  const pl = value - cost
                  
                  return (
                    <tr key={asset.id}>
                      <td><strong>{asset.symbol}</strong></td>
                      <td>{asset.amount.toFixed(8)}</td>
                      <td>${asset.purchasePrice.toFixed(2)}</td>
                      <td>${asset.currentPrice.toFixed(2)}</td>
                      <td>${value.toFixed(2)}</td>
                      <td className={pl >= 0 ? 'positive' : 'negative'}>
                        ${pl.toFixed(2)}
                      </td>
                      <td>
                        <button 
                          onClick={() => handleRemoveAsset(asset.id)}
                          className="button-small danger"
                        >
                          Remove
                        </button>
                      </td>
                    </tr>
                  )
                })}
              </tbody>
            </table>
          ) : (
            <p className="empty-message">
              No assets yet. Click &quot;Add Asset&quot; to get started.
            </p>
          )}
        </div>
      </div>

      <div className="security-info">
        <p>🔒 All data is encrypted and stored locally on your device</p>
      </div>
    </div>
  )
}
