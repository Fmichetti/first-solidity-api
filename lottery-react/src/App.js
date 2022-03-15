
import React, { Component } from 'react'

import './App.css';
import lottery from './lottery';
import web3 from './web3';

class App extends Component {
  state = {
    manager: '',
    players: [],
    balance: '',
    vale: '',
    message: ''
  }

  async componentDidMount() {
    const manager = await lottery.methods.manager().call();
    const players = await lottery.methods.getPlayers().call();
    const balance = await web3.eth.getBalance(lottery.options.address);

    this.setState({ manager, players, balance });
  }

  onSubmit = async (event) => {
    event.preventDefault();

    const accounts = await web3.eth.getAccounts();

    this.setState({ message: 'Waiting on transaction success...' });

    await lottery.methods.enter().send({
      from: accounts[0],
      value: web3.utils.toWei(this.state.value, 'ether')
    });

    this.setState({ message: 'You have been entered!' });

  };

  pickWinner = async () => {

    const accounts = await web3.eth.getAccounts();

    this.setState({ message: 'Waiting on transaction success...' });
    
    await lottery.methods.pickWinner().send({
      from: accounts[0]
    })

    this.setState({ message: 'A winner has been picked!' });


  };

  render() {
    return (
      <div>
        <h2>Lottery contract</h2>
        <p>This contract is managed by: {this.state.manager}.</p>
        <p>There are curently: {this.state.players.length} people entered trying to win {web3.utils.fromWei(this.state.balance, 'ether')}</p>

        <hr />

        <form onSubmit={this.onSubmit}>
          <h4>Want to try your luck?</h4>
          <div>
            <label>Amount of ether to enter </label>
            <input value={this.state.value} onChange={event => this.setState({ value: event.target.value })} />
          </div>
          <button>Enter</button>
        </form>

        <hr />

        <h4>Ready to pick a winner?</h4>
        <button onClick={this.pickWinner}>Pick a winner!</button>

        <hr />

        <h3> {this.state.message} </h3>
      </div>
    );
  }
}

export default App;
