//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";
import "@chainlink/contracts/src/v0.8/ConfirmedOwner.sol";

contract APIConsumer is ChainlinkClient, ConfirmedOwner {
    using Chainlink for Chainlink.Request;

    uint256 public risk;
    uint256 public risk1;
    bytes32 private jobId;
    uint256 private fee;
    string api;
    string public a = "0xd882cfc20f52f2599d84b8e8d58c7fb62cfe344b";
    string jas;

    event RequestRisk(bytes32 indexed requestId, uint256 risk);
    event Test(uint256 rischio);

    /**
     * @notice Initialize the link token and target oracle
     *
     * Goerli Testnet details:
     * Link Token: 0x326C977E6efc84E512bB9C30f76E30c160eD06FB
     * Oracle: 0xCC79157eb46F5624204f47AB42b3906cAA40eaB7 (Chainlink DevRel)
     * jobId: ca98366cc7314957b8c012c72f05aeeb
     *
     */

    constructor() ConfirmedOwner(msg.sender) {
        setChainlinkToken(0x326C977E6efc84E512bB9C30f76E30c160eD06FB);
        setChainlinkOracle(0xCC79157eb46F5624204f47AB42b3906cAA40eaB7);
        jobId = "ca98366cc7314957b8c012c72f05aeeb";
        fee = (1 * LINK_DIVISIBILITY) / 10; // 0,1 * 10**18 (Varies by network and job)
    }

    function setAddresstoCheck (string calldata __a) public {
        a=__a;
    } 

    // Set the path to find the desired data in the API response, where the response format is:
    // {
    //"data":{
    //  "0x6e1db9836521977ee93651027768f7e0d5722a33":{
    //      "risk":{
    //          "score":....
    //              }
    //      }
    //    }
    // }

    function __toStringAPI() public view returns (string memory API){
        string memory prima = "https://demo.anchainai.com/api/address_risk_score?proto=eth&address=";
        string memory centro = a;
        string memory dopo = "&apikey=demo_api_key";
        API = string(abi.encodePacked(prima, centro,dopo));
    }

    function __toStringPath() public view returns (string memory path){
        string memory prima = "data,";
        string memory centro = a;
        string memory dopo = ",risk,score";
        path = string(abi.encodePacked(prima, centro,dopo));
    }

    function requestRiskData() public returns (bytes32 requestId) {
        if (bytes(a).length > 0) {

        Chainlink.Request memory req = buildChainlinkRequest(jobId, address(this), this.fulfill.selector);
        //string memory prima = "data";
        //string memory dopo = ",risk,score";
        //string memory s1 = string(abi.encodePacked(prima, a, dopo));
        //prima = "https://demo.anchainai.com/api/address_risk_score?proto=eth&address=";
        //string memory centro = a;
        //dopo = "&apikey=demo_api_key";
        //string memory u = string(abi.encodePacked(prima, a, dopo));
        //api = string(abi.encodePacked(prima, centro,dopo));
        req.add("get", __toStringAPI());
        //string memory prima1 = "data,";
        //string memory centro1 = a;
        //string memory dopo1 = ",risk,score";
        //jas = string(abi.encodePacked(prima1, centro1, dopo1));
        req.add("path", __toStringPath());
        
        //Obbligatorio fare il times non funge altrimenti
        int256 timesAmount = 10;
        req.addInt("times", timesAmount);


        return sendChainlinkRequest(req, fee);
        }
    }

    function fulfill( bytes32 _requestId, uint256 _risk) public recordChainlinkFulfillment(_requestId) {
        emit RequestRisk(_requestId, _risk);
        return _risk;
        
    }

    function withdrawLink() public onlyOwner {
        LinkTokenInterface link = LinkTokenInterface(chainlinkTokenAddress());
        require( link.transfer(msg.sender, link.balanceOf(address(this))), "Unable to transfer");
    }

    }