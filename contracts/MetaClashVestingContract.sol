// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

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
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

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
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
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
    constructor() {}

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

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() external view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() external onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) external onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract MetaClashVesting is Ownable {
    using SafeMath for uint256;

    IERC20 public _tokenInstance;

    uint256 public constant ONE_DAY = 1 days;

    address immutable  public seedSaleWallet;
    address immutable public privateSaleWallet;
    address immutable public publicSaleWallet;
    address immutable public nftWallet;
    address immutable public listingAndLiquidityWallet;

    address immutable  public teamWallet;
    address immutable public advisorWallet;

    uint256 public constant SEED_WALLET_SHARE = 3 * 10**9 * 10**18;
    uint256 public constant PRIVATE_SALE_SHARE = 13 * 10**9 * 10**18;
    uint256 public constant PUBLIC_SALE_SHARE = 2 * 10**9 * 10**18;
    uint256 public constant NFT_SALE_SHARE = 31 * 10**8 * 10**18;
    uint256 public constant LISTING_LIQUIDITY_SHARE = 3 * 10**9 * 10**18;

    uint256 public constant TEAM_SHARE = 15 * 10**9 * 10**18;
    uint256 public constant ADVISOR_SHARE = 5 * 10**9 * 10**18;

    uint256 public immutable totalLocked =
        SEED_WALLET_SHARE
            .add(PRIVATE_SALE_SHARE)
            .add(PUBLIC_SALE_SHARE)
            .add(NFT_SALE_SHARE)
            .add(TEAM_SHARE)
            .add(ADVISOR_SHARE);

    uint256 public seedSaleClaimed;
    uint256 public privateSaleClaimed;
    uint256 public publicSaleClaimed;
    uint256 public nftClaimed;
    uint256 public listingAndLiquidityClaimed;

    uint256 public teamClaimed;
    uint256 public advisorClaimed;

    uint256 public publicShareNoOfClaims;

    uint256 private immutable ONE_MONTH = uint256(30).mul(ONE_DAY);

    uint256 public seedSaleReleaseTime;
    uint256 public privateSaleReleaseTime;
    uint256 public publicSaleReleaseTime;
    uint256 public nftReleaseTime;
    uint256 public liquidityReleaseTime;
    uint256 public teamReleaseTime;
    uint256 public advisorReleaseTime;

    event OnSeedSaleClaim(uint256 amount);
    event OnPrivateSaleClaim(uint256 amount);
    event OnPublicSaleClaim(uint256 amount);
    event OnNFTSaleClaim(uint256 amount);
    event OnListingAndLiquidityClaim(uint256 amount);
    event OnAdvisorAndLiquidityClaim(uint256 amount);
    event OnTeamClaim(uint256 amount);

    constructor(
        address token,
        address _seedSaleWallet,
        address _privateSaleWallet,
        address _publicSaleWallet,
        address _nftWallet,
        address _listingAndLiquidityWallet,
        address _teamWallet,
        address _advisorWallet
    ) {
        require(_seedSaleWallet != address(0), "Invalid Address");
        require(_privateSaleWallet != address(0), "Invalid Address");
        require(_publicSaleWallet != address(0), "Invalid Address");
        require(_nftWallet != address(0), "Invalid Address");
        require(_listingAndLiquidityWallet != address(0), "Invalid Address");
        require(_teamWallet != address(0), "Invalid Address");
        require(_advisorWallet != address(0), "Invalid Address");

        seedSaleWallet = _seedSaleWallet;
        privateSaleWallet = _privateSaleWallet;
        publicSaleWallet = _publicSaleWallet;
        nftWallet = _nftWallet;
        listingAndLiquidityWallet = _listingAndLiquidityWallet;
        teamWallet = _teamWallet;
        advisorWallet = _advisorWallet;

        seedSaleReleaseTime = block.timestamp;
        privateSaleReleaseTime = block.timestamp;
        publicSaleReleaseTime = block.timestamp;
        nftReleaseTime = block.timestamp;
        liquidityReleaseTime = block.timestamp;
        teamReleaseTime = block.timestamp.add(ONE_MONTH.mul(12)); // after 12 months
        advisorReleaseTime = block.timestamp.add(ONE_MONTH.mul(12)); // after 12 months

        _tokenInstance = IERC20(token);
    }

    function getContractBalance() external view returns (uint256) {
        return _tokenInstance.balanceOf(address(this));
    }

    function claimSeedSaleShare() external {
        require(seedSaleWallet == msg.sender, "Not authorized");
        require(seedSaleReleaseTime < block.timestamp, "Time not passed");
        require(seedSaleClaimed < SEED_WALLET_SHARE, "All Claimed");
        uint256 amount = SEED_WALLET_SHARE.div(20);
        seedSaleReleaseTime = block.timestamp.add(ONE_MONTH);
        seedSaleClaimed = seedSaleClaimed.add(amount);
        _tokenInstance.transfer(seedSaleWallet, amount);
        emit OnSeedSaleClaim(amount);
    }

    function claimPrivateSaleShare() external {
        require(privateSaleWallet == msg.sender, "Not authorized");
        require(privateSaleReleaseTime < block.timestamp, "Time not passed");
        require(privateSaleClaimed < PRIVATE_SALE_SHARE, "All Claimed");
        uint256 amount = PRIVATE_SALE_SHARE.div(20);
        privateSaleReleaseTime = block.timestamp.add(ONE_MONTH);
        privateSaleClaimed = privateSaleClaimed.add(amount);
        _tokenInstance.transfer(privateSaleWallet, amount);
        emit OnPrivateSaleClaim(amount);
    }

    function claimPublicSaleShare() external {
        require(publicSaleWallet == msg.sender, "Not authorized");
        require(publicSaleReleaseTime < block.timestamp, "Time not passed");
        require(publicSaleClaimed < PUBLIC_SALE_SHARE, "All Claimed");
        uint256 amount = 0;
        if (publicShareNoOfClaims == 0) {
            amount = PUBLIC_SALE_SHARE.mul(100).div(1000);
        } else if (
            publicShareNoOfClaims == 1 ||
            publicShareNoOfClaims == 2 ||
            publicShareNoOfClaims == 3
        ) {
            amount = PUBLIC_SALE_SHARE.mul(200).div(1000);
        } else if (publicShareNoOfClaims == 4) {
            amount = PUBLIC_SALE_SHARE.mul(300).div(1000);
        }

        publicShareNoOfClaims = publicShareNoOfClaims.add(1);
        publicSaleReleaseTime = block.timestamp.add(ONE_MONTH);
        publicSaleClaimed = publicSaleClaimed.add(amount);
        _tokenInstance.transfer(publicSaleWallet, amount);
        emit OnPublicSaleClaim(amount);
    }

    function claimNFTShare() external {
        require(nftWallet == msg.sender, "Not authorized");
        require(nftReleaseTime < block.timestamp, "Time not passed");
        require(nftClaimed < NFT_SALE_SHARE, "All Claimed");
        uint256 amount = NFT_SALE_SHARE.div(10);
        nftReleaseTime = block.timestamp.add(ONE_MONTH);
        nftClaimed = nftClaimed.add(amount);
        _tokenInstance.transfer(nftWallet, amount);
        emit OnNFTSaleClaim(amount);
    }

    function claimListingAndLiquidityShare() external {
        require(listingAndLiquidityWallet == msg.sender, "Not authorized");
        require(liquidityReleaseTime < block.timestamp, "Time not passed");
        require(
            listingAndLiquidityClaimed < LISTING_LIQUIDITY_SHARE,
            "All Claimed"
        );

        uint256 amount = 0;
        if (listingAndLiquidityClaimed == 0) {
            amount = LISTING_LIQUIDITY_SHARE.mul(400).div(1000);
            liquidityReleaseTime = block.timestamp.add(ONE_MONTH.mul(3));
        } else {
            amount = LISTING_LIQUIDITY_SHARE.mul(25).div(1000);
            liquidityReleaseTime = block.timestamp.add(ONE_MONTH);
        }
        listingAndLiquidityClaimed = listingAndLiquidityClaimed.add(amount);
        _tokenInstance.transfer(listingAndLiquidityWallet, amount);
        emit OnListingAndLiquidityClaim(amount);
    }

    function claimTeamShare() external {
        require(teamWallet == msg.sender, "Not authorized");
        require(teamReleaseTime < block.timestamp, "Time not passed");
        require(teamClaimed < TEAM_SHARE, "All Claimed");

        uint256 amount = TEAM_SHARE.mul(4167).div(100000);
        teamReleaseTime = block.timestamp.add(ONE_MONTH);
        teamClaimed = teamClaimed.add(amount);
        _tokenInstance.transfer(teamWallet, amount);
        emit OnTeamClaim( amount);

    }

    function claimAdvisorShare() external {
        require(advisorWallet == msg.sender, "Not authorized");
        require(advisorReleaseTime < block.timestamp, "Time not passed");
        require(advisorClaimed < ADVISOR_SHARE, "All Claimed");

        uint256 amount = ADVISOR_SHARE.mul(4167).div(100000);
        advisorReleaseTime = block.timestamp.add(ONE_MONTH);
        advisorClaimed = advisorClaimed.add(amount);
        _tokenInstance.transfer(advisorWallet, amount);
        emit OnAdvisorAndLiquidityClaim( amount);

    }
}
