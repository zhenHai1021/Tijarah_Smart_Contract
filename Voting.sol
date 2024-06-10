
// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

contract System {
    address payable private systemOwner;

    struct Member{
        address memberAddress;
        string memberName;
        // true if the member has NOMINATED THE other member
        bool hasNominated; 
        // no. of the members has been NOMINATED BY the other 
        uint256 noOfNominates;
    }

    struct WinnerHistory{
        address winnerAddress;
        string winnerName;
        uint256 nominatesWon;
        uint256 dateWon;
    }

    constructor(){
        systemOwner = payable (msg.sender);
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
        nominateMember(0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2, 0x5c6B0f7Bf3E7ce046039Bd8FABdfD3f9F5021678);
        //N4 -3
        nominateMember(0x617F2E2fD72FD9D5503197092aC168c91465E7f2, 0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB);
        //N5 -1
        nominateMember(0x17F6AD8Ef982297579C203069C1DbfFE4348c372, 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2);
        //N6 -1
       // nominateMember(0x5c6B0f7Bf3E7ce046039Bd8FABdfD3f9F5021678, 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2);
       
    }
    function setSystemAddress(address _address) public{
        systemOwner = payable(_address);
    }
    function getSystemAddress() public view returns (address){
        return payable(systemOwner);
    }

    event RegisterMember(address indexed _member, Member member);
    event Nomination(address indexed nominater, address indexed nominee);
    event Winner(address indexed winner, string memberName, uint256 noOfNominates);
    event RunOffRequired(address[] tieCandidates);
    mapping (address => Member[]) internal registeredMembers;
    mapping (address => WinnerHistory[]) internal winnersWon;
    mapping (address => mapping (address => bool)) private memberExists;

    modifier onlyOwner(){
        require(msg.sender == systemOwner, "Only system owner able to perform.");
        _;
    }

    function registerMember(address _memberAddress, string memory _name) public onlyOwner{
        require(_memberAddress != address(0), "Invalid Address");
        require(!memberExists[getSystemAddress()][_memberAddress], "Member already Exist.");
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

    function getAllMember(address _address) public view returns (Member[] memory){
        Member[] memory allMembers = new Member[](registeredMembers[_address].length);
        for(uint256 i=0; i< registeredMembers[_address].length;i++){
            allMembers[i] = registeredMembers[_address][i];
        }
        return allMembers;
    }

    function isMemberRegistered(address _owner, address _member) public view returns (bool){
        for(uint256 i = 0; i< registeredMembers[_owner].length;i++){
            if(registeredMembers[_owner][i].memberAddress == _member){
                return true;
            }
        }
        return false;
    }

    //self, others
    function nominateMember(address nominater, address nominee) public {
        require(isMemberRegistered(systemOwner, nominater), "Nominater not registered");
        require(isMemberRegistered(systemOwner, nominee), "Nominee not registered");
        require(nominater != nominee, "Nominater cannot nominate themselves");

        for (uint256 i = 0; i < registeredMembers[systemOwner].length; i++) {
            if (registeredMembers[systemOwner][i].memberAddress == nominater) {
                require(registeredMembers[systemOwner][i].hasNominated == false, "You had voted a nominee.");
                registeredMembers[systemOwner][i].hasNominated = true;
            }
            if (registeredMembers[systemOwner][i].memberAddress == nominee) {
                registeredMembers[systemOwner][i].noOfNominates += 1;
            }
        }
        emit Nomination(nominater, nominee);
    }

    function getWinner() public onlyOwner 
    //returns (address winner)
    {
        Member memory finaleWinner;
        uint256 maxNomination =0;
        bool isTie = false;
        address[] memory tieMembers;
        uint256 tieCount = 0;
        
        for(uint256 i = 0; i< registeredMembers[getSystemAddress()].length;i++){
            if(registeredMembers[getSystemAddress()][i].noOfNominates > maxNomination){
                maxNomination = registeredMembers[getSystemAddress()][i].noOfNominates;
                tieCount = 1;
                tieMembers = new address[](registeredMembers[getSystemAddress()].length);
                tieMembers[0] = registeredMembers[getSystemAddress()][i].memberAddress;
                isTie = false;
            }
            else if (registeredMembers[getSystemAddress()][i].noOfNominates == maxNomination) {
                tieMembers[tieCount] = registeredMembers[getSystemAddress()][i].memberAddress;
                tieCount++;
                isTie = true;
            }
        }
        if(isTie){
            //finaleWinner
            if(winnersWon[getSystemAddress()].length == 0){
                finaleWinner = registeredMembers[getSystemAddress()]
                [uint256(keccak256(abi.encodePacked(block.timestamp, block.prevrandao))) % tieCount];
            }else{
                finaleWinner = getWinnerFromHistory(tieMembers, tieCount);
            }
        }else{
             for (uint256 i = 0; i < registeredMembers[getSystemAddress()].length; i++) {
                if (registeredMembers[getSystemAddress()][i].noOfNominates == maxNomination) {
                    finaleWinner = registeredMembers[getSystemAddress()][i];
                    break;
                }
            }
        }
       
        addWinnerHistory(finaleWinner.memberAddress, finaleWinner.memberName, finaleWinner.noOfNominates, block.timestamp);
        //reset value
        for (uint256 i = 0; i < registeredMembers[getSystemAddress()].length; i++) {
            registeredMembers[getSystemAddress()][i].hasNominated = false;
            registeredMembers[getSystemAddress()][i].noOfNominates = 0;
            memberExists[getSystemAddress()][(registeredMembers[getSystemAddress()][i].memberAddress)] = true;
        }
        
       // return(finaleWinner.memberAddress);
    }

    function getWinnerFromHistory(address[] memory tieMembers, uint256 tieCount) internal view returns (Member memory) {
        uint256 highestVotes = 0;
        address highestVotesAddress;
        for (uint256 i = 0; i < tieCount; i++) {
            WinnerHistory[] memory history = winnersWon[tieMembers[i]];
            for (uint256 j = 0; j < history.length; j++) {
                if (history[j].nominatesWon > highestVotes) {
                    highestVotes = history[j].nominatesWon;
                    highestVotesAddress = tieMembers[i];
                }
            }
        }
        for (uint256 i = 0; i < registeredMembers[getSystemAddress()].length; i++) {
            if (registeredMembers[getSystemAddress()][i].memberAddress == highestVotesAddress) {
                return registeredMembers[getSystemAddress()][i];
            }
        }
        return registeredMembers[getSystemAddress()][uint256(keccak256(abi.encodePacked(block.timestamp, block.prevrandao))) % tieCount];
    }

    function addWinnerHistory(address _finaleAddress, string memory _finaleName, uint256 _finaleNominates, uint256 _date
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
        for(uint256 i=0;i<winnersWon[getSystemAddress()].length;i++){
            allWinnerHistory[i] = winnersWon[getSystemAddress()][i];
        }
        return allWinnerHistory;
    }
}

contract Nominater{
    System internal forSystem;
    address payable private nominaterAddress;
    
    struct Member{
        address memberAddress;
        string memberName;
        // true if the member has NOMINATED THE other member
        bool hasNominated; 
        // true if the member has been NOMINATED BY the other 
        bool isNominated;
    }

    constructor(address _systemAddress,
    address _nominatedAddress){
        forSystem = System(_systemAddress);
        require(forSystem.isMemberRegistered(forSystem.getSystemAddress(), _nominatedAddress), "Member Not Registered.");
        setNominaterAddress(payable(address(_nominatedAddress)));
    }
    modifier onlyNominater()
    {
        require(msg.sender == getNominaterAddress(), "Only nominaters can perform.");
        _;
    }
    function getNominaterAddress() public view returns (address){
        return payable(address(nominaterAddress));
    }
    function setNominaterAddress(address _address) internal {
        nominaterAddress = payable(_address);
    }

    function listMember() onlyNominater public view returns(
       string memory
    ){
        System.Member[] memory members = forSystem.getAllMember(forSystem.getSystemAddress());
        string memory memberList = "";
        for(uint256 i=0;i<members.length;i++){
            memberList = string (abi.encodePacked(
                memberList,
                uint2str(i+1), ": ",
                members[i].memberName, 
                ", Address: ", 
                toString(members[i].memberAddress), "\n"
            ));
        }
        return memberList;
    }

    //https://www.geeksforgeeks.org/type-conversion-in-solidity/
    function toString(address _addr) internal pure returns (string memory) {
        bytes32 value = bytes32(uint256(uint160(_addr)));
        bytes memory alphabet = "0123456789abcdef";
         
        bytes memory str = new bytes(42);
        str[0] = '0';
        str[1] = 'x';
         
        for (uint256 i = 0; i < 20; i++) {
            str[2 + i * 2] = alphabet[uint8(value[i + 12] >> 4)];
            str[3 + i * 2] = alphabet[uint8(value[i + 12] & 0x0f)];
        }
         
        return string(str);
    }

    //https://stackoverflow.com/questions/47129173/how-to-convert-uint-to-string-in-solidity
    function uint2str(uint _i) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len;
        while (_i != 0) {
            k = k-1;
            uint8 temp = (48 + uint8(_i - _i / 10 * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }

    function vote(address _nominee) onlyNominater public{
        forSystem.nominateMember(getNominaterAddress(), _nominee);
    } 
    
}
