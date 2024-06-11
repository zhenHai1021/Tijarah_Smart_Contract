// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

/*
@title: Ballot Voting System
@author: Hue Zhen Wei
@notice: Description of the function’s behavior.
@dev: 
**NOTE**
1. Please RUN the contract "System" first
2. Then COPY the contract "System"'s contract address and 
nominater's address to deploy the contract "Nominater" as nominaters

*/

contract System {
    address payable private systemOwner;

    struct Member {
        address memberAddress;
        string memberName;
        // true if the member has NOMINATED THE other member
        bool hasNominated;
        // no. of the members has been NOMINATED BY the other
        uint256 noOfNominates;
    }

    struct WinnerHistory {
        address winnerAddress;
        string winnerName;
        uint256 nominatesWon;
        uint256 dateWon;
    }

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor() {
        systemOwner = payable(msg.sender);
        registerMember(0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2, "N1");
        registerMember(0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db, "N2");
        registerMember(0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB, "N3");
        registerMember(0x617F2E2fD72FD9D5503197092aC168c91465E7f2, "N4");
        registerMember(0x17F6AD8Ef982297579C203069C1DbfFE4348c372, "N5");
        registerMember(0x5c6B0f7Bf3E7ce046039Bd8FABdfD3f9F5021678, "N6");

        /*
        //N3 Win
        //N1
        nominateMember(0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2, 0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB);
        //N4
        nominateMember(0x617F2E2fD72FD9D5503197092aC168c91465E7f2, 0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB);
        */

        //Tie N3 & N6
        //N1 -6
        nominateMember(
            0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2,
            0x5c6B0f7Bf3E7ce046039Bd8FABdfD3f9F5021678
        );
        //N4 -3
        nominateMember(
            0x617F2E2fD72FD9D5503197092aC168c91465E7f2,
            0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB
        );
        //N5 -2
        nominateMember(
            0x17F6AD8Ef982297579C203069C1DbfFE4348c372,
            0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db
        );
        //N6 -3
        //nominateMember(0x5c6B0f7Bf3E7ce046039Bd8FABdfD3f9F5021678, 0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB);
    }

    /**
     * @dev Set the contract address for `owner`.
     */
    function setSystemAddress(address _address) public {
        systemOwner = payable(_address);
    }

    /**
     * @dev Get the contract address for `owner`.
     */
    function getSystemAddress() public view returns (address) {
        return payable(systemOwner);
    }

    /**
     * @dev Emitted when the new `_member` is registered to the Member. `member` is the new registered to the Member struct
     */
    event RegisterMember(address indexed _member, Member member);

    /**
     * @dev Emitted when the addresses of both `nominater` has nominated, while the `nominee` been nominated
     */
    event Nomination(address indexed nominater, address indexed nominee);

    /**
     * @dev Emitted when the `winner` address has won from the voting, `memberName` and `noOfNominates` is stored in the WinnerHistory struct
     */
    event Winner(address indexed winner, string memberName, uint256 noOfNominates);

    /**
     * @dev mapping from an address to multiple of `Member` in array without public explicitly
     */
    mapping(address => Member[]) internal registeredMembers;

    /**
     * @dev mapping from an address to multiple of winners to `WinnerHistory` in array without public explicitly
     */
    mapping(address => WinnerHistory[]) internal winnersWon;

    /**
     * @dev mapping from an address to the specific address's the status of exists to prevent fraud
     */
    mapping(address => mapping(address => bool)) private memberExists;

    modifier onlyOwner() {
        require(
            msg.sender == systemOwner,
            "Only system owner able to perform."
        );
        _;
    }


     /*
     * @dev register a member
     *
     * Requirements:
     *
     * - `_memberAddress` cannot be the zero address and cannot be exist before
     * - Push both inputs `memberAddress` and `_name`, 
     * - defualt `hasNominated` and `noOfNominates` is set to FALSE and 0
     *
     * @notice: To register
     *
     * Emits a { memberExists} event.
     */
    function registerMember(address _memberAddress, string memory _name)
        public
        onlyOwner
    {
        require(_memberAddress != address(0), "Invalid Address");
        require(
            !memberExists[getSystemAddress()][_memberAddress],
            "Member already Exist."
        );
        Member memory newMember = Member({
            memberAddress: _memberAddress,
            memberName: _name,
            hasNominated: false,
            noOfNominates: 0
        });
        registeredMembers[getSystemAddress()].push(newMember);
        emit RegisterMember(getSystemAddress(), newMember);
        memberExists[getSystemAddress()][_memberAddress] = true;
    }

    /**
     * @dev get all the members registered
     *
     * Requirements:
     *
     * - `_memberAddress` cannot be the zero address and cannot be exist before
     * - Push both inputs `memberAddress` and `_name`, 
     * - defualt `hasNominated` and `noOfNominates` is set to FALSE and 0
     *
     * Emits a { memberExists} event.
     */
    function getAllMember(address _address)
        public
        view
        returns (Member[] memory)
    {
        Member[] memory allMembers = new Member[](
            registeredMembers[_address].length
        );
        for (uint256 i = 0; i < registeredMembers[_address].length; i++) {
            allMembers[i] = registeredMembers[_address][i];
        }
        return allMembers;
    }

    /**
     * @dev Returns the bool if the conditions met
     *
     * Requirements:
     *
     * - `_owner` for the contract address mapped
     * - `_member` as the input if it is same as the `_owner`
     * - defualt `hasNominated` and `noOfNominates` is set to FALSE and 0
     *
     */
    function isMemberRegistered(address _owner, address _member)
        public
        view
        returns (bool)
    {
        for (uint256 i = 0; i < registeredMembers[_owner].length; i++) {
            if (registeredMembers[_owner][i].memberAddress == _member) {
                return true;
            }
        }
        return false;
    }

    //self, others
    /**
     * @dev To nominate a member
     *
     * Requirements:
     *
     * - `nominater` cannot be zero address
     * - `_member` as the input if it is same as the `_owner`
     * - defualt `hasNominated` and `noOfNominates` is set to FALSE and 0
     *
     */
    function nominateMember(address nominater, address nominee) public {
        require(
            nominater != address(0) && nominee != address(0),
            "Invalid Address"
        );
        require(
            isMemberRegistered(systemOwner, nominater),
            "Nominater not registered"
        );
        require(
            isMemberRegistered(systemOwner, nominee),
            "Nominee not registered"
        );
        require(nominater != nominee, "Nominater cannot nominate themselves");

        for (uint256 i = 0; i < registeredMembers[systemOwner].length; i++) {
            if (registeredMembers[systemOwner][i].memberAddress == nominater) {
                require(
                    registeredMembers[systemOwner][i].hasNominated == false,
                    "You had voted a nominee."
                );
                registeredMembers[systemOwner][i].hasNominated = true;
            }
            if (registeredMembers[systemOwner][i].memberAddress == nominee) {
                registeredMembers[systemOwner][i].noOfNominates += 1;
            }
        }
        emit Nomination(nominater, nominee);
    }

    //several loops save for gas
    function getWinner() public onlyOwner {
        Member[] memory tiedMembers;
        uint256 maxNomination = 0;
        uint256 tieCount = 0;

        for (
            uint256 i = 0;
            i < registeredMembers[getSystemAddress()].length;
            i++
        ) {
            if (
                registeredMembers[getSystemAddress()][i].noOfNominates >
                maxNomination
            ) {
                maxNomination = registeredMembers[getSystemAddress()][i]
                    .noOfNominates;
                tieCount = 1;
                tiedMembers = new Member[](tieCount);
                tiedMembers[0] = registeredMembers[getSystemAddress()][i];
            } else if (
                registeredMembers[getSystemAddress()][i].noOfNominates ==
                maxNomination
            ) {
                tieCount++;
                Member[] memory newTiedMembers = new Member[](tieCount);
                for (uint256 j = 0; j < tiedMembers.length; j++) {
                    newTiedMembers[j] = tiedMembers[j];
                }
                newTiedMembers[tiedMembers.length] = registeredMembers[
                    getSystemAddress()
                ][i];
                tiedMembers = newTiedMembers;
            }
        }

        if (tieCount > 1) {
            uint256 randomIndex = uint256(
                keccak256(abi.encodePacked(block.timestamp, block.prevrandao))
            ) % tieCount;
            Member memory finaleWinner = tiedMembers[randomIndex];
            addWinnerHistory(
                finaleWinner.memberAddress,
                finaleWinner.memberName,
                finaleWinner.noOfNominates,
                block.timestamp
            );
        } else if (tieCount == 1) {
            Member memory finaleWinner = tiedMembers[0];
            addWinnerHistory(
                finaleWinner.memberAddress,
                finaleWinner.memberName,
                finaleWinner.noOfNominates,
                block.timestamp
            );
        }

        //reset
        for (
            uint256 i = 0;
            i < registeredMembers[getSystemAddress()].length;
            i++
        ) {
            registeredMembers[getSystemAddress()][i].hasNominated = false;
            registeredMembers[getSystemAddress()][i].noOfNominates = 0;
        }
        //delete all?
        // clearAllMembers();
    }

    function addWinnerHistory(
        address _finaleAddress,
        string memory _finaleName,
        uint256 _finaleNominates,
        uint256 _date
    ) internal {
        require(_finaleAddress != address(0), "Address Error.");
        WinnerHistory memory winnerWon = WinnerHistory({
            winnerAddress: _finaleAddress,
            winnerName: _finaleName,
            nominatesWon: _finaleNominates,
            dateWon: _date
        });
        winnersWon[getSystemAddress()].push(winnerWon);
        emit Winner(_finaleAddress, _finaleName, _finaleNominates);
    }

    function getWinnerHistory() public view returns (WinnerHistory[] memory) {
        WinnerHistory[] memory allWinnerHistory = new WinnerHistory[](
            winnersWon[getSystemAddress()].length
        );
        for (uint256 i = 0; i < winnersWon[getSystemAddress()].length; i++) {
            allWinnerHistory[i] = winnersWon[getSystemAddress()][i];
        }
        return allWinnerHistory;
    }

    function clearAllMembers() internal onlyOwner {
        delete registeredMembers[getSystemAddress()];

        for (
            uint256 i = 0;
            i < registeredMembers[getSystemAddress()].length;
            i++
        ) {
            delete memberExists[getSystemAddress()][
                registeredMembers[getSystemAddress()][i].memberAddress
            ];
        }
    }
}

contract Nominater {
    System internal forSystem;
    address payable private nominaterAddress;

    struct Member {
        address memberAddress;
        string memberName;
        // true if the member has NOMINATED THE other member
        bool hasNominated;
        // true if the member has been NOMINATED BY the other
        bool isNominated;
    }

    constructor(address _systemAddress, address _nominatedAddress) {
        forSystem = System(_systemAddress);
        require(
            forSystem.isMemberRegistered(
                forSystem.getSystemAddress(),
                _nominatedAddress
            ),
            "Member Not Registered."
        );
        setNominaterAddress(payable(address(_nominatedAddress)));
    }

    modifier onlyNominater() {
        require(
            msg.sender == getNominaterAddress(),
            "Only nominaters can perform."
        );
        _;
    }

    function getNominaterAddress() public view returns (address) {
        return payable(address(nominaterAddress));
    }

    function setNominaterAddress(address _address) internal {
        nominaterAddress = payable(_address);
    }

    function listMember() public view onlyNominater returns (string memory) {
        System.Member[] memory members = forSystem.getAllMember(
            forSystem.getSystemAddress()
        );
        string memory memberList = "";
        for (uint256 i = 0; i < members.length; i++) {
            memberList = string(
                abi.encodePacked(
                    memberList,
                    uint2str(i + 1),
                    ": ",
                    members[i].memberName,
                    ", Address: ",
                    toString(members[i].memberAddress),
                    "\n"
                )
            );
        }
        return memberList;
    }

    //https://www.geeksforgeeks.org/type-conversion-in-solidity/
    function toString(address _addr) internal pure returns (string memory) {
        bytes32 value = bytes32(uint256(uint160(_addr)));
        bytes memory alphabet = "0123456789abcdef";

        bytes memory str = new bytes(42);
        str[0] = "0";
        str[1] = "x";

        for (uint256 i = 0; i < 20; i++) {
            str[2 + i * 2] = alphabet[uint8(value[i + 12] >> 4)];
            str[3 + i * 2] = alphabet[uint8(value[i + 12] & 0x0f)];
        }

        return string(str);
    }

    //https://stackoverflow.com/questions/47129173/how-to-convert-uint-to-string-in-solidity
    function uint2str(uint256 _i)
        internal
        pure
        returns (string memory _uintAsString)
    {
        if (_i == 0) {
            return "0";
        }
        uint256 j = _i;
        uint256 len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint256 k = len;
        while (_i != 0) {
            k = k - 1;
            uint8 temp = (48 + uint8(_i - (_i / 10) * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }

    function vote(address _nominee) public onlyNominater {
        forSystem.nominateMember(getNominaterAddress(), _nominee);
    }
}
