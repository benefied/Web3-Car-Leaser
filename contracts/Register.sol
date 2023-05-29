// SPDX-License-Identifier: MIT

pragma solidity^0.8.9;
import "./RentingNftMinter.sol";

contract Register is CarToken{

    struct CarLeaser{
        uint256 id;
        string message;
        bool isOwner;
    }
    struct CarMint{
        string carName;
        address carOwner;
        uint256 price;
        string details;
        string signature;
        bool leased;
        address rentedTo;
    }


    uint256 private counter;
    uint256 private carIdCounter;
    bool noMintRequest = true;
    mapping (address => CarLeaser) public carLeaserAddr;
    mapping (uint256 => CarMint) internal carMinter;

    modifier onlyCarLeasers(){
        require(carLeaserAddr[msg.sender].isOwner, "this is only for car leasers");
        _;
    }

 function RegisterAsCarLeaser(string memory _message) public{
     carLeaserAddr[msg.sender].id = counter;
     carLeaserAddr[msg.sender].message = _message;
     carLeaserAddr[msg.sender].isOwner = true;
     counter++;
 }

function PutUpForRental(string memory _carName, uint256 _price, string memory _details, string memory _signature) public onlyCarLeasers{
     uint _id = carIdCounter;

     uint256 etherAmount =_price * 10 ** 18;

     carMinter[_id].carName = _carName;
     carMinter[_id].carOwner = msg.sender;
     carMinter[_id].price = etherAmount;
     carMinter[_id].details = _details;
     carMinter[_id].leased = false;
     carMinter[_id].signature = _signature;

     safeMint(msg.sender);
     carIdCounter++;
}

function Rent(uint256 _carId) public payable{
    require(msg.value >= carMinter[_carId].price, "not enough ethers");
     carMinter[_carId].rentedTo = msg.sender;
}

function ApproveRecieve(uint256 _carId) public{
    require(carMinter[_carId].rentedTo == msg.sender, "wasnt rented to you");
    carMinter[_carId].leased = true;
}

function TransferToCarOwner() internal{

}

function returnOwnersMessage(address _addr) public view returns(string memory){
    return carLeaserAddr[_addr].message;
}
function isAcarLeaser(address _addr) public view returns(bool){
    return carLeaserAddr[_addr].isOwner;
}
function amountOfCarLeasers() public view returns(uint){
    return counter;
}




}
