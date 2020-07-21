pragma solidity 0.4.24;

contract ElectionCommission
{
    address public Election_Commission;
    
    struct ElectionOfficer_INFO
    {
        address PublicKey;
        string Name;
        bool Serving; 
    }
    
    mapping(address => ElectionOfficer_INFO)EO_INFOS;
    
    constructor() public
    {
        Election_Commission = msg.sender;
    }
    
    
    function addElectionOfficers(address PublicKey,string Name) public
    {
        require(Election_Commission==msg.sender," Only Election Commission has the authority to add Election Officers");
        require(EO_INFOS[PublicKey].Serving == false ," Officer already exist");
        
        EO_INFOS[PublicKey] = ElectionOfficer_INFO(PublicKey,Name,true);
    }
    
    
    function removeElectionOfficer(address PublicKey) public 
    {
        require(Election_Commission == msg.sender,"Only Election Commission has the authority to remove Election Officers");
        require(EO_INFOS[PublicKey].Serving==false,"Not a member");
        
        EO_INFOS[PublicKey].Serving = false;
    }
    
    function isServing(address PublicKey) external view
    returns(bool)
    {
        if(EO_INFOS[PublicKey].Serving == true)
            return true;
        else
            return false;
    }
}


contract Ballot is ElectionCommission
{
    address ElectionOfficer;
    address winner;
    
    bool startElection = false;
    bool endElection = false;
    
    struct Candidate_Info
    {
        address PublicKey;
        string Name;
        bool isCandidate;
        uint32 TotalVoteReceived;
    }
    
    struct Voter_Info
    {
        address PublicKey;
        string Name;
        bool isVoter;
        bool voted;
    }
   
    mapping(address => Candidate_Info)Candidate_Infos;
    mapping(address => Voter_Info)Voter_Infos;
   
    constructor(address Election_Officer) public
    {
        require(Election_Commission==msg.sender,"Only Election Commission has authority to deplay the contract");
        ElectionOfficer = Election_Officer;
    }
    
    function addCandidate(address PublicKey,string Name) public 
    {
        require(Election_Commission==msg.sender,"Only Election Commission has authority to add Candidates");
        Candidate_Infos[PublicKey] = Candidate_Info(PublicKey,Name,true,0);
    }
    
    function addVoter(address PublicKey,string Name) public 
    {
        require(ElectionOfficer == msg.sender,"Only Election Officer has authority to add Candidates");
        Voter_Infos[PublicKey] = Voter_Info(PublicKey,Name,true,false);
    }
    
    function start_Election() public{
        require(ElectionOfficer==msg.sender,"Only Election Officer can start the Election");
        startElection = true;
    }
    
    function end_Election() public{
        require(ElectionOfficer==msg.sender,"Only Election Officer can end the Election");
        endElection = true;
    }
    
    function giveVote(address to) public 
    {
        require(endElection==false,"Election is Over");
        require(startElection==true,"Election haven't started yet");
        require(Voter_Infos[msg.sender].isVoter==true,"Voter not registered");
        require(Voter_Infos[msg.sender].voted==false,"Already voted");
        require(Candidate_Infos[to].isCandidate==true,"Candidate not registered");
        
        Voter_Infos[msg.sender].voted = true;
        Candidate_Infos[to].TotalVoteReceived++;
        if(Candidate_Infos[winner].TotalVoteReceived<Candidate_Infos[to].TotalVoteReceived)
            winner = to;
    }
    
    function giveWinner() public view
    returns(string,uint32)
    {
        require(ElectionOfficer==msg.sender," Only Election Officer have right to show result");
        require(endElection==true,"Election is going on");
        return (Candidate_Infos[winner].Name,Candidate_Infos[winner].TotalVoteReceived);
    }

}



