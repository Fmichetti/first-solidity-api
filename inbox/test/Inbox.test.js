const assert = require('assert');
const ganache = require('ganache-cli');
const Web3 = require('web3'); // uppercase, because it is a constructor
const web3 = new Web3(ganache.provider());
const { interface, bytecode } = require('../compile');
require('dotenv').config();

let accounts;
let inbox;
const INITIAL_STRING = 'Hi there!';

beforeEach(async () => {
    // Get a list of all accounts
    accounts = await web3.eth.getAccounts();

    //Use one of those accounts to deploy the contract
    inbox = await new web3.eth.Contract(JSON.parse(interface))
        .deploy({ data: bytecode, arguments: [INITIAL_STRING] })
        .send({ from: accounts[0], gas: '1000000' })
});

describe('Inbox contract', () => {

    it('deploys a contract', () => {
        //se tiver endereço, significa que aconteceu com sucesso o deploy do contrato
        assert.ok(inbox.options.address);
    });

    it('has a default message', async () => {
        const message = await inbox.methods.message().call();
        assert.equal(message, INITIAL_STRING);
    });

    it('can update the message', async () => {
        await inbox.methods.setMessage('Updated message').send({ from: accounts[0] });
        const message = await inbox.methods.message().call();
        assert.equal(message, 'Updated message');
    });
});