// SPDX-License-Identifier: MIT

pragma solidity^0.8.9;
import "./RentingNftMinter.sol";

contract Register is CarToken{

    struct CarOwner{
        uint256 id;
        address carOwner;
        uint256 rentals;
        string message;
    }
    struct CarMint{
        address carOwner;
        uint256 trackerId;
        string  plateNumber;
        string signature;
    }

 CarOwner[] public carOwners;

uint256 private counter;
 mapping(uint => bool) public approved;

 function requestForRegister(string memory _message) public{
     carOwners.push(CarOwner({
         id: counter,
         carOwner: msg.sender,
         rentals: counter,
         message: _message
     }));
     approved[counter] = false;
     counter++;
 }


function ApproveRegister(uint _id) public onlyOwner{
    approved[_id] = true;
}

function PutUpForRental(string memory name, string memory details, uint256 price) public payable {
     
}

function ApproveRental(uint256 _id) public{

}

function MintCarToken(uint256 _id) public{
    
}



function Rent(uint _id) public{

}
function ApproveRecievedCar(uint256 _id) external{
    _transferOwnership(newOwner);
}




}
