const { test } = require('../service')

const testFunc = async (req, res) => {
    try {
        const options = {
          chaincodeId: 'demo',
          fcn: 'test',
          args: [],
          chainId: 'mychannel',
        }
        const result = await test('network-user1', options)
        res.json(result)
      } catch(e) {
        res.status(500).json({ error: e.message })
      }
}
  
module.exports = testFunc