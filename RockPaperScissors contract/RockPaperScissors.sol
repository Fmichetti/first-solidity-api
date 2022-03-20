// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract RockPaperScissors {
    struct Player {
        uint256 lastWinning;
        uint256 lastBet;
        ChallengesRequest[] challenges;
    }

    struct ChallengesRequest {
        uint256 value;
        address playerOne;
        address playerTwo;
        bool isStarted;
    }

    mapping(address => Player) private players;
    mapping(address => bool) public playersLobby;

    modifier restricted() {
        require(playersLobby[msg.sender]);
        _;
    }

    function joinLobby() public {
        playersLobby[msg.sender] = true;
    }

    function challengePlayer(address challengedPlayer)
        public
        payable
        restricted
    {
        require(challengedPlayer != msg.sender);

        Player storage playerOne = players[msg.sender];
        Player storage playerTwo = players[challengedPlayer];

        ChallengesRequest memory newChallenge = ChallengesRequest({
            value: msg.value,
            playerOne: msg.sender,
            playerTwo: challengedPlayer,
            isStarted: false
        });

        playerOne.challenges.push(newChallenge);
        playerTwo.challenges.push(newChallenge);
    }

    function sentChallenges() public view returns (ChallengesRequest[] memory) {
        return players[msg.sender].challenges;
    }

    function acceptChallenge(uint256 challengeId)
        public
        payable
        restricted
        returns (address)
    {
        ChallengesRequest storage challengeConfig = players[msg.sender]
            .challenges[challengeId];

        require(msg.value == challengeConfig.value);
        require(challengeConfig.playerTwo == msg.sender);
        require(!challengeConfig.isStarted);

        challengeConfig.isStarted = true;
        challengeConfig.value = challengeConfig.value + msg.value;

        return
            address(
                new Game(
                    challengeConfig.playerOne,
                    challengeConfig.playerTwo,
                    challengeConfig.value
                )
            );
    }
}

contract Game {
    struct Move {
        string playerOneMovement;
        string playerTwoMovement;
    }

    address public playerOne;
    address public playerTwo;
    uint256 public value;
    string public gameStatus;
    bool private canPlay;
    Move[] public gameMoves;

    constructor(
        address pOne,
        address pTwo,
        uint256 gameValue
    ) {
        playerOne = pOne;
        playerTwo = pTwo;
        value = gameValue;
        canPlay = true;
        gameStatus = "Waiting P1 and P2 moves";

        Move memory firstRound = Move({
            playerOneMovement: "",
            playerTwoMovement: ""
        });

        gameMoves.push(firstRound);
    }

     modifier restricted() {
        require(canPlay);
        _;
    }

    function makeMovePlayerOne(string memory move) public restricted {
        require(playerOne == msg.sender);
        require(
            checkStringEqual(move, "rock") ||
                checkStringEqual(move, "paper") ||
                checkStringEqual(move, "scissors")
        );

        Move storage currentRound = gameMoves[gameMoves.length - 1];

        require(checkStringEqual(currentRound.playerOneMovement, ""));

        currentRound.playerOneMovement = move;

        if (!checkStringEqual(currentRound.playerTwoMovement, "")) {
            checkResult();
        } else {
            gameStatus = "Waiting P2 move";
        }
    }

    function makeMovePlayerTwo(string memory move) public restricted {
        require(playerTwo == msg.sender);
        require(
            checkStringEqual(move, "rock") ||
                checkStringEqual(move, "paper") ||
                checkStringEqual(move, "scissors")
        );

        Move storage currentRound = gameMoves[gameMoves.length - 1];

        require(checkStringEqual(currentRound.playerTwoMovement, ""));

        currentRound.playerTwoMovement = move;

        if (!checkStringEqual(currentRound.playerOneMovement, "")) {
            checkResult();
        } else {
            gameStatus = "Waiting P1 move";
        }
    }

    function checkResult() private restricted {
        Move storage currentRound = gameMoves[gameMoves.length - 1];

        require(
            !checkStringEqual(currentRound.playerOneMovement, "") &&
                !checkStringEqual(currentRound.playerTwoMovement, "")
        );

        if (
            checkStringEqual(
                currentRound.playerOneMovement,
                currentRound.playerTwoMovement
            )
        ) {
            //tie
        } else if (checkStringEqual(currentRound.playerOneMovement, "rock")) {
            if (checkStringEqual(currentRound.playerTwoMovement, "paper")) {
                //player one lose
                finishGame(playerTwo);
            } else {
                //player one wins
                finishGame(playerOne);
            }
        } else if (checkStringEqual(currentRound.playerOneMovement, "paper")) {
            if (checkStringEqual(currentRound.playerTwoMovement, "scissors")) {
                //player one lose
                finishGame(playerTwo);
            } else {
                //player one wins
                finishGame(playerOne);
            }
        } else if (
            checkStringEqual(currentRound.playerOneMovement, "scissors")
        ) {
            if (checkStringEqual(currentRound.playerTwoMovement, "rock")) {
                //player one lose
                finishGame(playerTwo);
            } else {
                //player one wins
                finishGame(playerOne);
            }
        }
    }

    function setTie() private restricted {
        Move memory nextRound = Move({
            playerOneMovement: "",
            playerTwoMovement: ""
        });

        gameMoves.push(nextRound);

        gameStatus = " TIE!! Waiting P1 and P2 moves ";
    }

    function finishGame(address winner) private restricted {
        payable(winner).transfer(value);

        gameStatus = "This game is finished!";
        canPlay = false;
    }

    function checkStringEqual(string memory string1, string memory string2)
        private
        pure
        returns (bool)
    {
        return keccak256(bytes(string1)) == keccak256(bytes(string2));
    }
}
