// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFV2WrapperConsumerBase.sol";
import "@chainlink/contracts/src/v0.8/ConfirmedOwner.sol";

contract Lottery is VRFV2WrapperConsumerBase, ConfirmedOwner {

    event RequestSent(uint256 requestId, uint32 numWords);
    event RequestFulfilled(
        uint256 requestId,
        uint256[] randomWords,
        uint256 payment
    );

    enum LOTTERY_STATE {
        OPEN,
        CLOSED,
        CALCULATING_WINNER
    }

    struct RequestStatus {
        uint256 paid; // amount paid in link
        bool fulfilled; // whether the request has been successfully fulfilled
        uint256[] randomWords;
    }

    mapping(uint256 => RequestStatus) public s_requests; /* requestId --> requestStatus */

    address public recentWinner;
    // past requests Id.
    uint256[] public requestIds;
    uint256 public lastRequestId;

    uint32 callbackGasLimit = 100000;

    // The default is 3, but you can set this higher.
    uint16 requestConfirmations = 3;

    // random words retrieved from the VRF service at a time
    uint32 numWords = 2;

    LOTTERY_STATE public lotteryState;
    address payable[] public players;
    uint256 public entranceFee;
    AggregatorV3Interface internal ethToUsdPriceFeed;

    constructor(uint256 _entranceFee, address _priceFeedAddress, address _linkAddress, address _wrapperAddress)
    ConfirmedOwner(msg.sender)
    VRFV2WrapperConsumerBase(_linkAddress, _wrapperAddress)
    {
        lotteryState = LOTTERY_STATE.CLOSED;
        ethToUsdPriceFeed = AggregatorV3Interface(_priceFeedAddress);
        entranceFee = _entranceFee * (10 ** 18); // Formatting to adapt to Wei for clearer manipulation
    }

    function requestRandomWords() public onlyOwner {
        uint256 requestId = requestRandomness(
            callbackGasLimit,
            requestConfirmations,
            numWords
        );
        s_requests[requestId] = RequestStatus({
        paid: VRF_V2_WRAPPER.calculateRequestPrice(callbackGasLimit),
        randomWords: new uint256[](0),
        fulfilled: false
        });
        requestIds.push(requestId);
        lastRequestId = requestId;
        emit RequestSent(requestId, numWords);
    }

    function fulfillRandomWords(uint256 _requestId, uint256[] memory _randomWords) internal override {
        require(s_requests[_requestId].paid > 0, "request not found");
        s_requests[_requestId].fulfilled = true;
        s_requests[_requestId].randomWords = _randomWords;
        emit RequestFulfilled(
            _requestId,
            _randomWords,
            s_requests[_requestId].paid
        );
    }

    function getRequestStatus(uint256 _requestId) public view
    returns (uint256 paid, bool fulfilled, uint256[] memory randomWords)
    {
        require(s_requests[_requestId].paid > 0, "request not found");
        require(s_requests[_requestId].fulfilled, "still calculating the winner, it'll be ready in a moment!");
        RequestStatus memory request = s_requests[_requestId];
        return (request.paid, request.fulfilled, request.randomWords);
    }

    function enter() public payable {
        require(lotteryState == LOTTERY_STATE.OPEN, "There is no open lotteries for the moment, check back later !");
        // 50$ minimum
        require(msg.value >= getEntranceFee(), "Not enough money to enter the Lottery");
        players.push(payable(msg.sender));
    }

    function getEntranceFee() public view returns (uint256) {
        (,int256 latestPrice,,,) = ethToUsdPriceFeed.latestRoundData();
        uint256 adjustedPrice = uint256(latestPrice) * (10 ** 10); // int on 8 decimals, we refactor it to be on 18 decimals
        uint256 costToEnter = entranceFee * (10 ** 18) / adjustedPrice;
        return costToEnter;
    }

    function startLottery() public onlyOwner {
        require(lotteryState == LOTTERY_STATE.CLOSED, "Can't start a new lottery");
        lotteryState = LOTTERY_STATE.OPEN;
    }

    function endLottery() public onlyOwner {
        require(lotteryState == LOTTERY_STATE.OPEN, "There is no lottery to close");
        lotteryState = LOTTERY_STATE.CALCULATING_WINNER;
        requestRandomWords();
    }

    function pickWinner() public {
        (,,uint256[] memory randomWords) = getRequestStatus(lastRequestId);
        uint256 indexOfWinner = randomWords[0] % players.length;
        recentWinner = players[indexOfWinner];
        payable(recentWinner).transfer(address(this).balance);
        players = new address payable[](0);
        lotteryState = LOTTERY_STATE.CLOSED;
    }

    // Allow withdraw of Link tokens from the contract
    function withdrawLink(address _linkAddress) public onlyOwner {
        LinkTokenInterface link = LinkTokenInterface(_linkAddress);
        require(
            link.transfer(msg.sender, link.balanceOf(address(this))),
            "Unable to transfer"
        );
    }
}