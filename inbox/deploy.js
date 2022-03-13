const HDWalletProvider = require('@truffle/hdwallet-provider');
const Web3 = require('web3'); // uppercase, because it is a constructor
const { interface, bytecode } = require('./compile');

// specify which accout will be used to pay for contract deployment and
// witch network will be deployed
const provider = new HDWalletProvider(
    process.env.MNEMONICS,
    'https://rinkeby.infura.io/v3/8a3093529c194b66bd9300f4c23c7b8e'
);

//instance of web3
const web3 = new Web3(provider);

const deploy = async () => {
    const accounts = await web3.eth.getAccounts();

    console.log('Attempting to deploy from account:', accounts[0]);

    const result = await new web3.eth.Contract(JSON.parse(interface))
        .deploy({ data: bytecode, arguments: ['Hello world!'] })
        .send({ gas: '1000000', from: accounts[0] });

    console.log('Contract deployed to:', result.options.address);
    
    provider.engine.stop();
};

deploy();