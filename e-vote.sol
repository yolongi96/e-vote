pragma solidity ^0.4.24;

contract Vote {
    // structures

    struct Candidate
    { 
        address candidateAddress;
        uint districtIndex;
        uint candidateNo;
        bytes32 name; 
        bool registered;
        uint age;
        uint voteCount;  
    }

    struct Voter
    { 
        address voterAddress; // voter info
        bytes32 name;         // voter info
        bool registered;      // voter info
        bool voted;           // voter info
  
        uint candidateIndex;  // Candidate Index
        uint districtIndex;   // ElectionDistrict Index
    }

    struct ElectionDistrict
    { 
        //uint districtIndex;
        bytes32 name;
        bytes32 winnerName;    // winner Candidate Name
        //bool registered;
        //bool voted;
        //Candidate[] candidates;
        //Voter[] voters;
        //mapping( address => Voter ) voters;
     }

    // data

    address public ElectionChairman;
    
    //Candidate[][] public candidateList; 

    Candidate[] public candidates;
    ElectionDistrict[] public districts;
    //Voter[] public voters;
    bool open;
    
    //mapping( address => Voter ) voters;

    // function
    constructor() public
    {
        ElectionChairman = msg.sender;
    }
    
    modifier onlyChairman { require(msg.sender==ElectionChairman); _; }
    
    // "0x1111" / "0x1122"
    function distinctRegister( bytes32 name_ ) public
    {
        // districts[idx].districtIndex = idx;
        districts.push(ElectionDistrict({name: name_, winnerName: 0x20}));
    }
    
    // 0, 1, "0x2222", 46 / 0, 2, "0x2233", 56
    //mapping( address => Candidate ) public candidates;
    function candidateRegister( uint districtIndex_, uint candidateNo, bytes32 name_, uint age_ ) public
    {
        require( districts.length != 0 );
        require( districtIndex_ < districts.length );
        
        //candidates[msg.sender].candidateAddress = msg.sender;
        //candidates[msg.sender].districtIndex    = districtIndex_;
        //candidates[msg.sender].name             = name_;
        //candidates[msg.sender].registered       = true;
        //candidates[msg.sender].age              = age_;
        //candidates[msg.sender].voteCount        = 0;
        candidates.push(Candidate({candidateAddress: msg.sender, districtIndex:districtIndex_, candidateNo:candidateNo,name: name_, registered:true, age:age_, voteCount:0}));
    }

    function candidateWithdraw() public
    {
        //require( candidate[].candidateAddress != msg.sender );

        for (uint i=0; i<candidates.length; i++)
        {
            if (candidates[i].candidateAddress == msg.sender)
            {
                candidates[i].registered = false;
            }
        }
    }
    
    mapping( address => Voter ) public voters;
    modifier onlyElectionChairman {require(msg.sender == ElectionChairman);_;}
    
    // 0, "0x7777"
    function registerVoter( uint districtIndex, bytes32 name ) public {
        require(voters[msg.sender].registered == false);
        voters[msg.sender].voterAddress = msg.sender;
        voters[msg.sender].districtIndex = districtIndex;
        voters[msg.sender].name = name;
        voters[msg.sender].registered = true;
        //voters[msg.sender].voted = true;
    }
    
    function () public payable  {  }
    
    function currentEth() public view returns (uint){
        return address(this).balance;
    }
    
    function openVote() public onlyChairman {
        open = true;
    }
    
    function closeVote() public onlyChairman {
        open = false;
    }
    
    function voting( uint districtIndex_, uint candidateIndex_) public
    {
        require( voters[msg.sender].registered );
        require( !voters[msg.sender].voted );
        
        for (uint i=0; i < candidates.length; i++ )
        {
            if ( candidates[i].districtIndex == districtIndex_ )
            {
                if ( candidates[i].candidateNo == candidateIndex_ )
                {
                    candidates[i].voteCount++;
                    voters[msg.sender].voted = true;
                    
                    msg.sender.transfer(1 ether);
                }
            }
        }
    }
    
    function announceWinner() public {
        
        require( !open );
        uint highest=0;
        bytes32 name="";
        for(uint i=0; i<districts.length; i++ ) {
            highest=0;
            name="";
            for( uint j=0; j<candidates.length; j++ ) {
                if( i == candidates[j].districtIndex ) {
                    if( highest < candidates[j].voteCount ) {
                        highest = candidates[j].voteCount;
                        name = candidates[j].name;
                    }
                }
            }
            districts[i].winnerName = name;
        }
        
    }
}
