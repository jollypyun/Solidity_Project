pragma solidity^0.5.17;
contract Owned{
    address public owner;
    event TransferOwnership(address oldaddr, address newaddr);
    modifier onlyOwner() {
        if(msg.sender == owner) _;
    }
    
    function transferOwnership(address _new) public onlyOwner{
        address oldaddr = owner;
        owner = _new;
        emit TransferOwnership(oldaddr, owner);
    }
}

contract watt is Owned{
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;
    struct MemberStatus{
        string name;
        uint256 sum;
        int8 rate;
        int isprosumer;
    }
    
    struct History{
        uint256 sum;
        uint256 statusIndex;
    }

    MemberStatus[] public status;
    mapping(address => History) public  tradingHistory;
    mapping(address => uint256) public balance;
    mapping(address => int8) public isprosumer;
    mapping(address => uint256) public indexNum;
    mapping(uint256 => address) public personNum;
    mapping(address => uint256) public power;
    mapping(address => int8) public incentiveRate;
    address public owner;
    
    address warehouse1 = 0xdD870fA1b7C4700F2BD7f44238821C26f7392148;
    address warehouse2 = 0x583031D1113aD414F02576BD6afaBfb302140225;
    address warehouse3 = 0x4B0897b0513fdC7C541B6d9D7E929C4e5364D2dB;
    address head = 0xdc6B0983a2fb4cC923966073B6881627B2c9f1BB;

    modifier onlyOwner() {if(msg.sender == owner) _;}
    event Transfer(address from, address to, uint256 value);
    event isprosuming(address target);
    event RejectedPaymentFromNotRegister(address from, address to, uint256 value);
    event SetIncentive(address from, int8 rate);
    event Incentive(address from, address to, uint256 value);
    
    constructor(uint256 _supply, string memory _name, string memory _symbol, uint8 _decimals) public {
        
        balance[msg.sender] = _supply;
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        totalSupply = _supply;
        owner = msg.sender;
        
    }
    
    function setPower(address _addr, uint256 wattVolume, uint256 localNum) public {
        power[_addr] = wattVolume;
        indexNum[_addr] = localNum;
    }
    function register(address _addr, uint256 localNum) public onlyOwner{
        
        isprosumer[_addr] = 1;
        indexNum[_addr] = localNum;
      
        emit isprosuming(_addr);
    }
    function deleteRegister(address _addr) public onlyOwner{
        
        isprosumer[_addr]--;
        emit isprosuming(_addr);
    }

function GetIncentiveRate(int8 _rate) public {
    if(_rate<1){
        _rate = 0;
    }
    else if (_rate >100){
        _rate = 100;
    }
    incentiveRate[msg.sender] = _rate;
    
    emit SetIncentive(msg.sender, _rate);
}
    
    function sell(address _to, uint256 _value)  public payable{
        
              if(isprosumer[msg.sender]>0){
            emit RejectedPaymentFromNotRegister(msg.sender, _to, _value);
        }
    
        else{
            
            uint exchangeRate = 150;
            uint256 incentive=0;
            updateHistory(msg.sender, _value);
            
            incentive  =  uint256(getIncentiveRate(msg.sender));
            
            exchangeRate += exchangeRate * incentive;
            
            power[msg.sender] -= _value;
            power[_to] += _value;
            
            balance[msg.sender] +=_value * exchangeRate ;
            balance[_to] -= _value *exchangeRate ;
            
            
            
            emit Transfer(msg.sender, _to, _value);
            emit Incentive(_to, msg.sender, incentive);
        }
    }
    
    function checkPower(address _addr, uint256 _value) public view  returns(bool){
        
        if(power[_addr] > _value){
            return true;
        } 
        else{
            return false;
        }
    }
    function buy(uint256 _value) public payable{
        
    address _from;
    
    if(indexNum[msg.sender]==0x01 || indexNum[msg.sender]==1)
    {
        _from = warehouse1;
        
    }
    
        if(indexNum[msg.sender]==0x02 || indexNum[msg.sender]==2)
    {
         _from = warehouse2;
      
          
    }
            if(indexNum[msg.sender]==0x03 || indexNum[msg.sender]==3)
    {
         _from = warehouse3;
     
    }
    
    emit Transfer(msg.sender, _from, _value);
        
    }
    
    
    function moveWatt(address _from, address _to, uint256 _value) public{
        
        power[_to] += _value;
        power[_from] -= _value;
        
        emit Transfer(_from, _to, _value);
    }
    
    function pushStatus(string memory _name,  uint256 _sum, int8 _rate, int _isprosumer) public onlyOwner{
        
        status.push(
            MemberStatus(
                {
                    name: _name,
                    sum: _sum,
                    rate: _rate,
                    isprosumer: _isprosumer
                   
                })
            );
    }
    function editStatus(uint256 _index, string memory _name,  uint256 _sum, int8 _rate) public onlyOwner{
        if(_index < status.length){
            status[_index].name = _name;
            status[_index].sum = _sum;
            status[_index].rate = _rate;
            
        }
    }
    
    function updateHistory(address _member, uint256 _value) public{
        
        
        tradingHistory[_member].sum += _value;
        
        uint256 index;
        int8 tmprate;
        
        for(uint i = 0 ; i < status.length ; i++){
            
            if( tradingHistory[_member].sum >= status[i].sum && tmprate < status[i].rate){
                index=i;
                tmprate = status[i].rate;
            }
        }
        
        
        tradingHistory[_member].statusIndex = index;
    }
    
    function getIncentiveRate(address _member) public view returns (int8 rate){
        rate = status[tradingHistory[_member].statusIndex].rate;
    }

    
}
