pragma solidity ^0.4.21;
import "zos-lib/contracts/migrations/Migratable.sol";

contract Metadata is Migratable {

    function initialize(address _o) isInitializer("Metadata", "0") public {
        owner = _o;
        curators[_o] = true;
    }

    address owner;
    mapping(address => bool) curators;
    uint price = 30000000000000000;

    MetaData[] history;
    uint currentIndex = 0;
    mapping(address => MetaData[]) public versionHistory;
    mapping(address => MetaData) public adresses; 

    event SetData (
        address _address,
        string _logo_ipfs,
        uint index
    );

    struct MetaData {
        address _address;
        string _name;
        string _ipfs;
        bool _selfAttested;
        bool _curated;
        bool _exists;
        address _submitter;
    }  

    function setOwner(address _o) public {
        require(msg.sender == owner);
        owner = _o;
    }
    
    function addAddress(address _address, string _name, string _ipfs) public payable returns(string) {
        require(msg.value >= price, "Couldn't add because you underpaid");
        addInternal(_address, _name, _ipfs);
        return "You have added to the MetaData list!";
    }

    function addByCurator(address _address, string _name, string _ipfs) public {
        assert(isCurator(msg.sender));
        addInternal(_address, _name, _ipfs);
    }
    
    function addMultiple(address[] _addresses, string[] _names, string[] _hashes) public {
        assert(msg.sender == owner);
        for(uint i = 0; i < _addresses.length; i++) {
            addInternal(_addresses[i],_names[i],_hashes[i]);
        }
    }

    function addInternal(address _address, string _name, string _ipfs) private {

        bool selfAttested = false;
        if (_address == msg.sender) selfAttested = true;

        bool curator = isCurator(msg.sender);

        //We have a new MetaData!
        MetaData memory newData = MetaData(_address, _name, _ipfs, selfAttested, curator, true, msg.sender);
        
        history.push(newData);
        
        //is the current metadata self-attested or is submission by curator?
        if (_address == msg.sender || curator)
        {
            adresses[_address] = newData;   
        }
        //last submission was not made by sender, is not curated and not self-attested
        else if (adresses[_address]._address != msg.sender 
                    && adresses[_address]._selfAttested == false 
                    && adresses[_address]._curated == false) 
        {
                adresses[_address] = newData;
        }
        versionHistory[_address].push(newData);
        
        emit SetData(_address,_ipfs,currentIndex);
        currentIndex += 1;
    }
    
    function isCurator(address a) public view returns(bool)
    {
        return curators[a];
    }
    
    function addCurator(address a) public {
        require(msg.sender == owner);
        curators[a] = true;
    }
    
    function removeCurator(address a) public {
        require(msg.sender == owner);
        curators[a] = false;
    }

    function lootBox() public
    {
        require(msg.sender == owner);
        msg.sender.transfer(address(this).balance);
    }

    function getByAddress(address a) public view returns(address, string, string,bool,bool, address) 
    {
        return (adresses[a]._address, adresses[a]._name, adresses[a]._ipfs, adresses[a]._selfAttested, adresses[a]._curated, adresses[a]._submitter);
    }
    
    function getVersions(address a) public view returns(uint v)
    {
        return versionHistory[a].length;
    }
    
    function getHistoricalVersion(address a, uint i) public view returns(address, string, string,bool,bool, address)
    {
        return (versionHistory[a][i]._address,versionHistory[a][i]._name,versionHistory[a][i]._ipfs,versionHistory[a][i]._selfAttested,versionHistory[a][i]._curated, versionHistory[a][i]._submitter);
    }
    
    function setPrice(uint _price) public
    {
        require(msg.sender == owner);
        price = _price;
    }

    function getPrice() public view returns(uint)
    {
        return price;
    }
    
    function getOwner() public view returns(address)
    {
        return owner;
    }
    
    function getIndex() public view returns(uint) {
        return currentIndex;
    }
    
    function getByIndex(uint a)public view returns(address, string, string,bool,bool, address) 
    {
        return (history[a]._address, history[a]._name, history[a]._ipfs, history[a]._selfAttested, history[a]._curated, history[a]._submitter);
    }
}