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
        address requestedBy;
        string rentDuration;
        string status;
    }


    uint256 private counter;
    uint256 private carIdCounter;
    bool noMintRequest = true;
    mapping (address => CarLeaser) public carLeaserAddr;
    mapping (uint256 => CarMint) public carMinter;

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
     uint _carId = carIdCounter;
     uint256 etherAmount =_price * 10 ** 18;

     carMinter[_carId].carName = _carName;
     carMinter[_carId].carOwner = msg.sender;
     carMinter[_carId].price = etherAmount;
     carMinter[_carId].details = _details;
     carMinter[_carId].leased = false;
     carMinter[_carId].status = "available";
    
    bool _approved = true;
    address _operator = carMinter[_carId].requestedBy;
     safeMint(msg.sender);
     setApprovalForAll(_operator, _approved);
     carIdCounter++;
}

function Rent(uint256 _carId, string memory _rentDuration) public payable{
    require(!carMinter[_carId].leased, "not available for renting");
    require(msg.value >= carMinter[_carId].price, "not enough ethers");
    carMinter[_carId].requestedBy = msg.sender;
    carMinter[_carId].rentDuration = _rentDuration;
    carMinter[_carId].status = "requested";
}

function ApproveRent(uint256 _carId) public onlyCarLeasers{
    //require(carMinter[_carId].requestedBy == msg.sender, "not rented to you");
    require(carMinter[_carId].carOwner == msg.sender, "not the ownerof the car");
    carMinter[_carId].leased = true;
    address _from = msg.sender;
    address _to = carMinter[_carId].requestedBy;
    uint256 _tokenId = _carId;
    carMinter[_carId].leased = true;
    carMinter[_carId].status = "unavailable";
    TransferToCarOwner(_from, _to, _tokenId);
}
function DisApproveRent(uint256 _carId)public onlyCarLeasers{
    require(carMinter[_carId].carOwner == msg.sender, "not the ownerof the car");
    
    address _to = carMinter[_carId].requestedBy;
    uint256 _price = carMinter[_carId].price;
    payable(_to).transfer(_price);

    carMinter[_carId].requestedBy = address(0);
    carMinter[_carId].rentDuration = "0";
    carMinter[_carId].status = "available";
    
}

function TransferToCarOwner(address _from, address _to, uint256 _tokenId) internal{
    safeTransferFrom(_from, _to, _tokenId);
}

function ApproveRecieve(uint256 _carId) public{
    require(carMinter[_carId].requestedBy == msg.sender, "youre not the person its rented to");
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
