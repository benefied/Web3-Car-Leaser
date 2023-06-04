// SPDX-License-Identifier: MIT

pragma solidity^0.8.9;
import "./RentingNftMinter.sol";
import "hardhat/console.sol";

contract Register is CarToken{
    
    //struct to create car leaser i.e to be recognised as a car leaser with properties
    struct CarLeaser{
        uint256 id;
        string code;
        bool isOwner;
    }

    //struct to create a car structure with properties to identify, register and restrict a car minted NFT
    struct CarMint{
        string carName;
        address carOwner;
        uint256 price;
        string carLicenseDocs;
        bool leased;
        address requestedBy;
        uint256 timeSet;
        uint256 rentDuration;
        string status;
    }

    //a counter uint to counter and iterate a special counter for the carLeasers
    uint256 private counter;
    //a counter uint to counter and iterate a special counter for the Minted carNfts
    uint256 private carIdCounter;

    //to map an address to a carLeaser struct to create an identification map list
    mapping (address => CarLeaser) public carLeaserAddr;
    //to map a uint to a carMint struct to create identity and array-type structure
    mapping (uint256 => CarMint) public carMinter;

    //a modifier to require onlyCarLeaser to call a function
    modifier onlyCarLeasers(){
        require(carLeaserAddr[msg.sender].isOwner, "this is only for car leasers");
        _;
    }

//a function to register a user as a car Leaser 
 function RegisterAsCarLeaser(string memory _code) public{
     carLeaserAddr[msg.sender].id = counter;
     carLeaserAddr[msg.sender].code = _code;
     carLeaserAddr[msg.sender].isOwner = true;
     counter++;
 }

//a function to put a car up for leasing and mint an Nft for the car
function PutUpForRental(string memory _carName, uint256 _price, string memory _carLicenseDocs) public onlyCarLeasers{
     uint _carId = carIdCounter;
     uint256 etherAmount =_price * 10 ** 18;

     carMinter[_carId].carName = _carName;
     carMinter[_carId].carOwner = msg.sender;
     carMinter[_carId].price = etherAmount;
     carMinter[_carId].carLicenseDocs = _carLicenseDocs;
     carMinter[_carId].leased = false;
     carMinter[_carId].status = "available";
    
    bool _approved = true;
    address _operator = carMinter[_carId].requestedBy;
     safeMint(msg.sender);
     setApprovalForAll(_operator, _approved);
     carIdCounter++;
}

//function for any user rent a carand set the rent duration
function Rent(uint256 _carId, uint256 _rentDuration) public payable{
    require(!carMinter[_carId].leased, "not available for renting");
    require(msg.value >= carMinter[_carId].price, "not enough ethers");
    carMinter[_carId].requestedBy = msg.sender;
    carMinter[_carId].rentDuration = _rentDuration;
    carMinter[_carId].status = "requested";
}

//function for the owner of the car/carLeaser to approve the rent from any user that wants to rent
function ApproveRent(uint256 _carId) public onlyCarLeasers{
    require(carMinter[_carId].carOwner == msg.sender, "not the ownerof the car");
    carMinter[_carId].leased = true;
    address _from = msg.sender;
    address _to = carMinter[_carId].requestedBy;
    uint256 _tokenId = _carId;
    carMinter[_carId].leased = true;
    carMinter[_carId].status = "unavailable";
    TransferToLessee(_from, _to, _tokenId);
}

//function for the owner of the car/carLeaser to disApprove the rent from any user that wants to rent
function DisApproveRent(uint256 _carId)public onlyCarLeasers{
    require(carMinter[_carId].carOwner == msg.sender, "not the ownerof the car");
    
    address _to = carMinter[_carId].requestedBy;
    uint256 _price = carMinter[_carId].price;
    payable(_to).transfer(_price);

    carMinter[_carId].requestedBy = address(0);
    carMinter[_carId].rentDuration = 0;
    carMinter[_carId].status = "available";
}

//function for to transfer ownerShip from the owner/leaser to the lessee
function TransferToLessee(address _from, address _to, uint256 _tokenId) internal{
    safeTransferFrom(_from, _to, _tokenId);
}

//function for the lessee to approve that he has recieved the car and set the timer
function ApproveRecieve(uint256 _carId) public{
    require(carMinter[_carId].requestedBy == msg.sender, "youre not the person its rented to");
    address ownaddr = carMinter[_carId].carOwner;
    uint256 carPrice= carMinter[_carId].price;

    payable(ownaddr).transfer(carPrice);
    approve(ownaddr, _carId);
    startTimer(_carId);
}

//function to start the timer
function startTimer(uint256 _carId)internal{
        carMinter[_carId].timeSet = block.timestamp;
}

//a function to check if the timer is up and to collect the car nft
function collectCarBack(uint256 _carId) public onlyCarLeasers{
        uint256 timeset = carMinter[_carId].timeSet;
        uint256 duration = carMinter[_carId].rentDuration;
        require(block.timestamp > timeset + duration, "RENT TIME IS NOT UP YET");

        address _from = carMinter[_carId].requestedBy;
        address _to = msg.sender;
        uint256 _tokenId = _carId;

        safeTransferFrom(_from, _to, _tokenId);
}

//a function to return the owners signature code 
function returnOwnerscode(address _addr) public view returns(string memory){
    return carLeaserAddr[_addr].code;
}

//a function to check if an address is a carLeaser
function isAcarLeaser(address _addr) public view returns(bool){
    return carLeaserAddr[_addr].isOwner;
}

//a function to return the amount of car leasers
function amountOfCarLeasers() public view returns(uint){
    return counter;
}
}
