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
        bool leased;
        address rentedTo;
        string status;
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

function PutUpForRental(string memory _carName, uint256 _price, string memory _details) public onlyCarLeasers{
     uint _id = carIdCounter;
     uint256 etherAmount =_price * 10 ** 18;

     carMinter[_id].carName = _carName;
     carMinter[_id].carOwner = msg.sender;
     carMinter[_id].price = etherAmount;
     carMinter[_id].details = _details;
     carMinter[_id].leased = false;
     carMinter[_id].status = "available";
    
    bool _approved = true;
    address _operator = carMinter[_id].rentedTo;
     safeMint(msg.sender);
     setApprovalForAll(_operator, _approved);
     carIdCounter++;
}

function Rent(uint256 _carId) public payable{
    require(carMinter[_carId].leased, "not available for renting");
    require(msg.value >= carMinter[_carId].price, "not enough ethers");
     carMinter[_carId].rentedTo = msg.sender;
}

function ApproveRent(uint256 _carId) public onlyCarLeasers{
    //require(carMinter[_carId].rentedTo == msg.sender, "not rented to you");
    require(carMinter[_carId].carOwner == msg.sender, "not the ownerof the car");
    carMinter[_carId].leased = true;
    address _from = msg.sender;
    address _to = carMinter[_carId].rentedTo;
    uint256 _tokenId = _carId;
    carMinter[_carId].leased = true;
    carMinter[_carId].status = "unavailable";
    TransferToCarOwner(_from, _to, _tokenId);
}

function TransferToCarOwner(address _from, address _to, uint256 _tokenId) internal{
    safeTransferFrom(_from, _to, _tokenId);
}

function ApproveRecieve(uint256 _carId) public{
    require(carMinter[_carId].rentedTo == msg.sender, "youre not the person its rented to");
    address ownaddr = carMinter[_carId].carOwner;
    uint256 carPrice= carMinter[_carId].price;

    payable(ownaddr).transfer(carPrice);
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
