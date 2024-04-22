const migratorAbi = [
  {
      "type": "constructor",
      "inputs": [
          {
              "name": "definitiveOldVault",
              "type": "address",
              "internalType": "address"
          },
          {
              "name": "definitiveNewVault",
              "type": "address",
              "internalType": "address"
          },
          {
              "name": "definitiveAsset",
              "type": "address",
              "internalType": "address"
          }
      ],
      "stateMutability": "nonpayable"
  },
  {
      "type": "function",
      "name": "asset",
      "inputs": [],
      "outputs": [
          {
              "name": "",
              "type": "address",
              "internalType": "address"
          }
      ],
      "stateMutability": "view"
  },
  {
      "type": "function",
      "name": "migrate",
      "inputs": [
          {
              "name": "amount",
              "type": "uint256",
              "internalType": "uint256"
          },
          {
              "name": "owner",
              "type": "address",
              "internalType": "address"
          },
          {
              "name": "receiver",
              "type": "address",
              "internalType": "address"
          }
      ],
      "outputs": [],
      "stateMutability": "nonpayable"
  },
  {
      "type": "function",
      "name": "newVault",
      "inputs": [],
      "outputs": [
          {
              "name": "",
              "type": "address",
              "internalType": "address"
          }
      ],
      "stateMutability": "view"
  },
  {
      "type": "function",
      "name": "oldVault",
      "inputs": [],
      "outputs": [
          {
              "name": "",
              "type": "address",
              "internalType": "address"
          }
      ],
      "stateMutability": "view"
  }
];

export { migratorAbi };
