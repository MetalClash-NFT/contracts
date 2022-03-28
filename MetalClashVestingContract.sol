// SPDX-License-Identifier: MIT 


pragma solidity 0.8.4;

interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}



library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
    }
}



/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor()  {}

    function _msgSender() internal view returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// 
/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor()  {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), 'Ownable: caller is not the owner');
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), 'Ownable: new owner is the zero address');
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract MetalClashVesting  is Ownable{
    using SafeMath for uint256;
    
    
    IERC20 public _tokenInstance;

    uint256 public constant ONE_DAY = 1;



    address public seedSaleWallet;
    address public privateSaleWallet;
    address public publicSaleWallet;
    address public nftWallet;
    address public listingAndLiquidityWallet;
    // address public stakingAndGamingWallet;
    // address public ecoSystemWallet;
    address public teamWallet;
    address public advisorWallet;
    
    


    
    
    uint256 public constant SEED_WALLET_SHARE = 3000000000 *10**18;
    uint256 public constant PRIVATE_SALE_SHARE = 13000000000 *10**18;
    uint256 public constant PUBLIC_SALE_SHARE = 2000000000 *10**18;
    uint256 public constant NFT_SALE_SHARE = 3100000000 *10**18;
    uint256 public constant LISTING_LIQUIDITY_SHARE = 3000000000 *10**18;
    // uint256 public constant STAKING_SHARE = 40000000000 *10**18;
    // uint256 public constant ECOSYSTEM_SHARE = 15900000000 *10**18;
    uint256 public constant TEAM_SHARE = 15000000000 *10**18;
    uint256 public constant ADVISOR_SHARE = 5000000000 *10**18;

    uint256 public totalLocked = SEED_WALLET_SHARE.add(PRIVATE_SALE_SHARE).add(PUBLIC_SALE_SHARE).add(NFT_SALE_SHARE).add(TEAM_SHARE).add(ADVISOR_SHARE);


    uint256 public  seedSaleClaimed;
    uint256 public  privateSaleClaimed;
    uint256 public  publicSaleClaimed;
    uint256 public  nftClaimed;
    uint256 public  listingAndLiquidityClaimed;
    // uint256 public  stakingClaimed;
    // uint256 public  ecoSystemClaimed;
    uint256 public  teamClaimed;
    uint256 public  advisorClaimed;




    uint256 public publicShareNoOfClaims;



    uint256  ONE_MONTH = uint256(30).mul(ONE_DAY);




 

    
    uint256 public seedSaleReleaseTime;
    uint256 public privateSaleReleaseTime;
    uint256 public publicSaleReleaseTime;
    uint256 public nftReleaseTime;
    uint256 public liquidityReleaseTime;
    // uint256 public stakingReleaseTime;
    // uint256 public ecosystemReleaseTime;
    uint256 public teamReleaseTime;
    uint256 public advisorReleaseTime;

    
  

    constructor( 
        address token,
        address  _seedSaleWallet,
        address  _privateSaleWallet,
        address  _publicSaleWallet,
        address  _nftWallet,
        address  _listingAndLiquidityWallet,
        // address  _stakingAndGamingWallet,
        // address  _ecoSystemWallet,
        address  _teamWallet,
        address  _advisorWallet

    
        ) {
            

        seedSaleWallet = _seedSaleWallet;
        privateSaleWallet = _privateSaleWallet;
        publicSaleWallet = _publicSaleWallet;
        nftWallet = _nftWallet;
        listingAndLiquidityWallet = _listingAndLiquidityWallet;
        // stakingAndGamingWallet = _stakingAndGamingWallet;
        // ecoSystemWallet = _ecoSystemWallet;
        teamWallet = _teamWallet;
        advisorWallet = _advisorWallet;

    
        seedSaleReleaseTime = block.timestamp;
        privateSaleReleaseTime = block.timestamp;
        publicSaleReleaseTime = block.timestamp;
        nftReleaseTime = block.timestamp;
        liquidityReleaseTime = block.timestamp;
        // stakingReleaseTime = block.timestamp;
        // ecosystemReleaseTime=  block.timestamp;
        teamReleaseTime =block.timestamp.add(ONE_MONTH.mul(12)); // after 12 months
        advisorReleaseTime = block.timestamp.add(ONE_MONTH.mul(12)); // after 12 months

        _tokenInstance = IERC20(token);

    }
    
    
    
    function getContractBalance() public view returns (uint256){
        return _tokenInstance.balanceOf(address(this));
    }
    
    

    function claimSeedSaleShare() public{
        require(seedSaleWallet == msg.sender,"Not authorized");
        require(seedSaleReleaseTime< block.timestamp,"Time not passed");
        require(seedSaleClaimed < SEED_WALLET_SHARE,"All Claimed");
        uint256 amount = SEED_WALLET_SHARE.div(20);
        seedSaleReleaseTime = block.timestamp.add(ONE_MONTH);
        seedSaleClaimed = seedSaleClaimed.add(amount);
        _tokenInstance.transfer(seedSaleWallet,amount);

    }
    
    function claimPrivateSaleShare() public{
        require(privateSaleWallet == msg.sender,"Not authorized");
        require(privateSaleReleaseTime< block.timestamp,"Time not passed");
        require(privateSaleClaimed < PRIVATE_SALE_SHARE,"All Claimed");
        uint256 amount = PRIVATE_SALE_SHARE.div(20);
        privateSaleReleaseTime =  block.timestamp.add(ONE_MONTH);
        privateSaleClaimed = privateSaleClaimed.add(amount);
        _tokenInstance.transfer(privateSaleWallet,amount);
    }
    
    
    function claimPublicSaleShare() public{
        require(publicSaleWallet == msg.sender,"Not authorized");
        require(publicSaleReleaseTime< block.timestamp,"Time not passed");
        require(publicSaleClaimed < PUBLIC_SALE_SHARE,"All Claimed");
        uint256 amount = 0;
        if(publicShareNoOfClaims == 0){
            amount = PUBLIC_SALE_SHARE.mul(100).div(1000); // 10%
        }else if(publicShareNoOfClaims == 1 || publicShareNoOfClaims == 2 ||publicShareNoOfClaims == 3){
             amount = PUBLIC_SALE_SHARE.mul(200).div(1000); // 20%
        }else if(publicShareNoOfClaims == 4){
             amount = PUBLIC_SALE_SHARE.mul(300).div(1000); // 30%
        }
        
        publicShareNoOfClaims = publicShareNoOfClaims.add(1);
        publicSaleReleaseTime =  block.timestamp.add(ONE_MONTH);
        publicSaleClaimed = publicSaleClaimed.add(amount);
        _tokenInstance.transfer(publicSaleWallet,amount);
    }
    

    function claimNFTShare() public{
        require(nftWallet == msg.sender,"Not authorized");
        require(nftReleaseTime< block.timestamp,"Time not passed");
        require(nftClaimed < NFT_SALE_SHARE,"All Claimed");
        uint256 amount = NFT_SALE_SHARE.div(10);
        nftReleaseTime = block.timestamp.add(ONE_MONTH);
        nftClaimed = nftClaimed.add(amount);
        _tokenInstance.transfer(nftWallet,amount);
    }

     
    function claimListingAndLiquidityShare() public{
        require(listingAndLiquidityWallet == msg.sender,"Not authorized");
        require(liquidityReleaseTime< block.timestamp,"Time not passed");
        require(listingAndLiquidityClaimed < LISTING_LIQUIDITY_SHARE,"All Claimed");

        uint256 amount = 0;
        if(listingAndLiquidityClaimed == 0){
            amount = LISTING_LIQUIDITY_SHARE.mul(400).div(1000);//40
            liquidityReleaseTime = block.timestamp.add(ONE_MONTH.mul(3));
        }else{
            amount = LISTING_LIQUIDITY_SHARE.mul(25).div(1000); //2.5
            liquidityReleaseTime = block.timestamp.add(ONE_MONTH);
        }
        listingAndLiquidityClaimed = listingAndLiquidityClaimed.add(amount);
        _tokenInstance.transfer(listingAndLiquidityWallet,amount);
    }
    
    // function claimStakingAndGamingShare() public{
    //     require(stakingAndGamingWallet == msg.sender,"Not authorized");
    //     require(stakingReleaseTime< block.timestamp,"Time not passed");
    //     uint256 amount = STAKING_SHARE.div(36);
    //     stakingReleaseTime = block.timestamp.add(ONE_DAY.mul(30));
    //     stakingClaimed = stakingClaimed.add(amount);
    //     _tokenInstance.transfer(stakingAndGamingWallet,amount);
    // }
    


   
    
    
    
    
    // function claimEcoSystemShare() public{
    //     require(ecoSystemWallet == msg.sender,"Not authorized");
    //     require(ecosystemReleaseTime< block.timestamp,"Time not passed");
    //     uint256 amount = ECOSYSTEM_SHARE.div(24);
    //     ecosystemReleaseTime = block.timestamp.add(ONE_DAY.mul(30));
    //     ecoSystemClaimed = ecoSystemClaimed.add(amount);
    //     _tokenInstance.transfer(listingAndLiquidityWallet,amount);
    // }
    
    
        
    function claimTeamShare() public{
        require(teamWallet == msg.sender,"Not authorized");
        require(teamReleaseTime< block.timestamp,"Time not passed");
        require(teamClaimed < TEAM_SHARE,"All Claimed");

        uint256 amount = TEAM_SHARE.mul(4167).div(100000); // 4.167% 
        teamReleaseTime = block.timestamp.add(ONE_MONTH);
        teamClaimed = teamClaimed.add(amount);
        _tokenInstance.transfer(teamWallet,amount);
    }
    
    
    function claimAdvisorShare() public{
        require(advisorWallet == msg.sender,"Not authorized");
        require(advisorReleaseTime< block.timestamp,"Time not passed");
        require(advisorClaimed < ADVISOR_SHARE,"All Claimed");

        uint256 amount = ADVISOR_SHARE.mul(4167).div(100000); // 4.167% 
        advisorReleaseTime = block.timestamp.add(ONE_MONTH);
        advisorClaimed = advisorClaimed.add(amount);
        _tokenInstance.transfer(advisorWallet,amount);
    }
    

    

    






     
    

    
    
  
    
    
    
    
    
    
    
    
    
    
}