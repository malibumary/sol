pragma solidity ^0.4.18;

/**
deployed contract : 0x3371d358c634189517d4a012a892fe7fe0b280df
 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */

contract SafeMath {
    function safeMul(uint a, uint b) internal constant returns (uint256) {
        uint c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function safeDiv(uint a, uint b) internal constant returns (uint256) {
        uint c = a / b;
        return c;
    }

    function safeSub(uint a, uint b) internal constant returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function safeAdd(uint a, uint b) internal constant returns (uint256) {
        uint c = a + b;
        assert(c >= a);
        return c;
    }

    function max64(uint64 a, uint64 b) internal constant returns (uint64) {
        return a >= b ? a : b;
    }

    function min64(uint64 a, uint64 b) internal constant returns (uint64) {
        return a < b ? a : b;
    }

    function max256(uint256 a, uint256 b) internal constant returns (uint256) {
        return a >= b ? a : b;
    }

    function min256(uint256 a, uint256 b) internal constant returns (uint256) {
        return a < b ? a : b;
    }
}


contract Ownable {
    address public owner;


    /**
    * @dev The Ownable constructor sets the original `owner` of the contract to the sender
    * account.
    */
    function Ownable() public{
        owner = msg.sender;
    }


    /**
    * @dev Throws if called by any account other than the owner.
    */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }


    /**
    * @dev Allows the current owner to transfer control of the contract to a newOwner.
    * @param newOwner The address to transfer ownership to.
    */
    function transferOwnership(address newOwner) public onlyOwner {
        if (newOwner != address(0)) {
            owner = newOwner;
        }
    }

}

/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
    event Pause();
    event Unpause();

    bool public paused = false;


    /**
    * @dev modifier to allow actions only when the contract IS paused
    */
    modifier whenNotPaused() {
        require(!paused);
        _;
    }

    /**
    * @dev modifier to allow actions only when the contract IS NOT paused
    */
    modifier whenPaused {
        require(paused);
        _;
    }

    /**
    * @dev called by the owner to pause, triggers stopped state
    */
    function pause() public onlyOwner whenNotPaused returns (bool) {
        paused = true;
        Pause();
        return true;
    }

    /**
    * @dev called by the owner to unpause, returns to normal state
    */
    function unpause() public onlyOwner whenPaused returns (bool) {
        paused = false;
        Unpause();
        return true;
    }
}



contract ERC721Basic {
    event Transfer(address indexed _from, address indexed _to, uint256 _tokenId);
    event Approval(address indexed _owner, address indexed _approved, uint256 _tokenId);
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    function balanceOf(address _owner) public view returns (uint256 _balance);
    function ownerOf(uint256 _tokenId) public view returns (address _owner);
    function exists(uint256 _tokenId) public view returns (bool _exists);

    function approve(address _to, uint256 _tokenId) public;
    function getApproved(uint256 _tokenId) public view returns (address _operator);

    function setApprovalForAll(address _operator, bool _approved) public;
    function isApprovedForAll(address _owner, address _operator) public view returns (bool);

    function transferFrom(address _from, address _to, uint256 _tokenId) public;
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) public;
    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes _data
    )
        public;
}

/**
 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
 * @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
 */
contract ERC721Enumerable is ERC721Basic {
    function totalSupply() public view returns (uint256);
    function tokenOfOwnerByIndex(address _owner, uint256 _index) public view returns (uint256 _tokenId);
    function tokenByIndex(uint256 _index) public view returns (uint256);
}


/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
 */
contract ERC721Metadata is ERC721Basic {
    function name() public view returns (string _name);
    function symbol() public view returns (string _symbol);
    function tokenURI(uint256 _tokenId) public view returns (string);
}


/**
 * @title ERC-721 Non-Fungible Token Standard, full implementation interface
 * @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
 */
contract ERC721 is ERC721Basic, ERC721Enumerable, ERC721Metadata {
}




/// @title Exchange - Facilitates exchange of ERC20 tokens.
/// @author Amir Bandeali - <amir@0xProject.com>, Will Warren - <will@0xProject.com>
contract Exchange is SafeMath {
 
    mapping (address => mapping (address => mapping (uint => bool))) public NFtokens;
    mapping (address => uint) public weth;
    struct Auction { 
        address seller; 
        address NTFcontract;
        uint256 tokenID;
        uint256 fixedPrice;
        address taker;
    }
    //["0x7c68a2160575132fc9099b3573fdf1902c35c7fd","0x78286bc27d12d991892c93ae4ebdecf841479e52"],1
    function Tokencheck(address[2] tAddresses, uint256 tokenid) view public returns (bool){
        return NFtokens[tAddresses[0]][tAddresses[1]][tokenid];
    }
    
    function deposit() payable public{
        weth[msg.sender] = safeAdd(weth[msg.sender], msg.value); 
    }

    function withdraw(uint amount) public{
        if (weth[msg.sender] < amount) revert();
        weth[msg.sender] = safeSub(weth[msg.sender], amount);
        //이더 있는지 예외처리
        msg.sender.transfer(amount);
    }
    //0x7c68a2160575132fc9099b3573fdf1902c35c7fd,1
    function depositToken(address token, uint tokenid) public{
        //토큰 있는지 예외처리
        ERC721(token).transferFrom(msg.sender, this, tokenid);
        NFtokens[token][msg.sender][tokenid] = true; 
    }
    //0x7c68a2160575132fc9099b3573fdf1902c35c7fd,1
    function withdrawToken(address token, uint tokenid) public{
        if(NFtokens[token][msg.sender][tokenid] != true) revert();
        NFtokens[token][msg.sender][tokenid] = false;
        ERC721(token).transferFrom(this, msg.sender, tokenid);
    }
    
    //["0x78286bc27D12D991892c93AE4eBDEcF841479E52","0x7c68a2160575132fc9099b3573fdf1902c35c7fd","0x3371d358c634189517d4a012a892fe7fe0b280df"],[1,50000000000]
    function fillOrder(address[3] addereV, uint256[2] intV)
          public
          returns (bool)
    {
        //sign 확인 코드
        Auction memory order = Auction({
            seller: addereV[0],
            NTFcontract: addereV[1],
            tokenID: intV[0],
            fixedPrice: intV[1],
            taker: addereV[2]
        });
 
        if(weth[msg.sender]>=order.fixedPrice){
            if(Tokencheck([order.NTFcontract,order.seller],order.tokenID)==true){
                NFtokens[order.NTFcontract][order.seller][order.tokenID] = false;
                ERC721(order.NTFcontract).transferFrom(this, order.taker, order.tokenID);
                weth[msg.sender] = safeSub(weth[msg.sender], order.fixedPrice);
                weth[order.seller] = safeAdd(weth[order.seller], order.fixedPrice);
                return true;
            }
        }
        return false;
    }

}