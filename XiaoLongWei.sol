// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

/**
 * Xiao Long Wei
 * 
 * THE SNOWY DRAGON ROARS
 * 
 * Little LongWei is a movement. It’s the roar of the dragon, awakening a new era of decentralized possibilities. Are you ready to take flight?
 * 
 * Little LongWei is a community-driven, stealth launched DeFi Token providing a burn mechanism on buys and sells reducing supply on each transaction.
 * 
 * Twitter: https://twitter.com/XiaolongweiAvax
 * Website: https://xiaolongwei.tech/
 * Telegram: https://t.me/xiaolongweiportal 
 */

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
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
        return div(a, b, "SafeMath: division by zero");
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }
}

/**
 * IERC20 standard interface.
 */
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Context {
    //function _msgSender() internal view virtual returns (address payable) {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

/**
 * Allows for contract ownership along with multi-address authorization
 */
abstract contract Ownable is Context {
    address private _owner;

    /**
     * @dev The caller account is not authorized to perform an operation.
     */
    error OwnableUnauthorizedAccount(address account);

    /**
     * @dev The owner is not a valid owner account. (eg. `address(0)`)
     */
    error OwnableInvalidOwner(address owner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the address provided by the deployer as the initial owner.
     */
    constructor(address initialOwner) {
        if (initialOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(initialOwner);
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}


interface IDEXFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IDEXRouter {
    function factory() external pure returns (address);
    function WAVAX() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);

    function addLiquidityAVAX(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountAVAXMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountAVAX, uint liquidity);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function swapExactAVAXForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;

    function swapExactTokensForAVAXSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}


contract XiaoLongWei is IERC20, Ownable(msg.sender) {
    using SafeMath for uint256;

    address WAVAX;
    address constant DEAD = 0x000000000000000000000000000000000000dEaD;
    address constant ZERO = 0x0000000000000000000000000000000000000000;

    string constant _name = "XiaoLongWei";
    string constant _symbol = "XLW";
    uint8 constant _decimals = 18;

    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;
    mapping (address => bool) isFeeExempt;
    mapping (address => bool) isTxLimitExempt;
    mapping (address => bool) isMaxExempt;
    mapping (address => uint256) burnedInfo;

/**********
 * Events
 **********/
    event Burn(address indexed from, uint256 value);
    event AutoLiquify(uint256 amountAVAX, uint256 amount);
    
/**********
 * Amounts
 **********/

    uint256 _totalSupply = 1_000_000_000 * (10 ** _decimals);
    uint256 public _maxTxAmount = (_totalSupply / 100) * 2; 
    uint256 public _maxWalletToken = (_totalSupply / 100) * 2;
    uint256 public numberBurns = 0; // total number of times we've burned some supply through our taxes. 
    uint256 public totalBurned = 0; // total amount of tokens we've burned through our taxes.

/**********
 * Taxes
 **********/
    uint256 liquidityFee    = 5;
    uint256 marketingFee    = 20;
    uint256 public totalFee = liquidityFee.add(marketingFee);
    uint256 feeDenominator  = 100;

    uint256 public buyFee       = 5;
    uint256 public buyBurnFee   = 2;
    uint256 public sellBurnFee  = 2;

/**********
 * Wallets
 **********/
    address public autoLiquidityReceiver;
    address public marketingFeeReceiver;
    address public burnTo;
    
/**********
 * Pair Router
 **********/
    IDEXRouter public router;
    address public pair;

/**********
 * Launch Data
 **********/
    uint256 public launchedAt;
    bool public tradingOpen = false;

/**********
 * Swap
 **********/
    bool public swapEnabled = true;
    uint256 public swapThreshold = _totalSupply * 15 / 1000;
    bool inSwap;
    modifier swapping() { inSwap = true; _; inSwap = false; }

    // address routerAddress = 0x60aE616a2155Ee3d9A68541Ba4544862310933d4;
    // address WAVAX = 0xB31f66AA3C1e785363F0875A1B74E27b85FD66c7;
    constructor (address routerAddress, address _WAVAX) {
        WAVAX = _WAVAX;
        router = IDEXRouter(routerAddress);
        pair = IDEXFactory(router.factory()).createPair(WAVAX, address(this));
        
        _allowances[address(this)][address(router)] = type(uint256).max;

        autoLiquidityReceiver = msg.sender;
        marketingFeeReceiver = 0xdF8BB4900697f923727c850a21fC8A0213e0f0fa;

        isFeeExempt[msg.sender] = true;
        isTxLimitExempt[msg.sender] = true;
        isMaxExempt[msg.sender] = true;
        isMaxExempt[marketingFeeReceiver] = true;

        _balances[msg.sender] = _totalSupply;

        burnTo = DEAD;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    receive() external payable { }

    function totalSupply() external view override returns (uint256) { return _totalSupply; }
    function getCirculatingSupply() public view returns (uint256) { return _totalSupply.sub(balanceOf(DEAD)).sub(balanceOf(ZERO)); }
    function decimals() external pure override returns (uint8) { return _decimals; }
    function symbol() external pure override returns (string memory) { return _symbol; }
    function name() external pure override returns (string memory) { return _name; }
    function getOwner() external view override returns (address) { return owner(); }
    function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }
    function approveMax(address spender) external returns (bool) { return approve(spender, type(uint256).max); }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if(_allowances[sender][msg.sender] != type(uint256).max){
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount, "Insufficient Allowance");
        }

        return _transferFrom(sender, recipient, amount);
    }

    //settting the maximum permitted wallet holding (percent of total supply)
     function setMaxWalletPercent(uint256 maxWallPercent) external onlyOwner() {
        if(maxWallPercent > 100) {
            revert("Max percent cannot be greater than 100%");
        }

        if(maxWallPercent < 1) {
            revert("Max percent cannot be less than 1%");
        }
        _maxWalletToken = (_totalSupply / 100) * maxWallPercent;
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        if(inSwap){ return _basicTransfer(sender, recipient, amount); }

        if(sender != owner() && recipient != owner()){
            require(tradingOpen,"Trading not open yet");
        }

        if (recipient != address(this) && 
            recipient != address(DEAD) && 
            recipient != pair && 
            recipient != marketingFeeReceiver &&
            recipient != autoLiquidityReceiver
        ){
            uint256 heldTokens = balanceOf(recipient);
            if(!isMaxExempt[recipient]) {
                require((heldTokens + amount) <= _maxWalletToken,"ExceedMaxWalletException: Unable to process as you will exceed max wallet");
            }
        }

        bool inSell = (recipient == pair);
        bool inTransfer = (recipient != pair && sender != pair);

        // Checks max transaction limit
        // but no point if the recipient is exempt
        // this check ensures that someone that is buying and is txnExempt then they are able to buy any amount
        if(!isTxLimitExempt[recipient]) {
            checkTxLimit(sender, amount);
        }
                
        // Checks max transaction limit
        checkTxLimit(sender, amount);

        //Exchange tokens
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");

        uint256 amountAfterTax = amount;

        if(!inTransfer) {
            if(shouldSwapBack()){ swapBack(); }
            amountAfterTax = shouldTakeFee(sender) ? takeFee(sender, amount, inSell) : amount;
        }

        _balances[recipient] = _balances[recipient].add(amountAfterTax);
        emit Transfer(sender, recipient, amountAfterTax);
        return true;
    }
    
    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function checkTxLimit(address sender, uint256 amount) internal view {
        require(amount <= _maxTxAmount || isTxLimitExempt[sender], "TX Limit Exceeded");
    }

    function shouldTakeFee(address sender) internal view returns (bool) {
        if(isFeeExempt[sender]) return false;
        if(totalFee == 0) return false;

        return true;
    }

    /// Takes the taxes from the amount of tokens we're transferring, also calculates the burn amount and actions that burn
    /// @param sender the address of the sender of the tokens
    /// @param amount the amount of tokens that is being transferred
    /// @param isSell boolean to determine if this is a sell or a buy
    function takeFee(address sender, uint256 amount, bool isSell) internal returns (uint256) {

        // thing to remember is the burn fee that we set is inclusive of the fill fee
        // so totalFee is 6 and we have a 3 burn fee then the actual fee to take is 3 and 3 is burned
        // vs. taking a fee and then also taking the burn as this would actually be a double tax 
        // on the person buying / selling / transferring which we dont want as that's a bit of a dick move
        uint256 feeToTake = isSell ? totalFee.sub(sellBurnFee) : buyFee.sub(buyBurnFee);

        uint256 burnToTake = isSell ? sellBurnFee : buyBurnFee;
        uint256 feeAmount = amount.mul(feeToTake).mul(100).div(feeDenominator * 100);
        uint256 burnAmount = burnToTake > 0 ? amount.mul(burnToTake).mul(100).div(feeDenominator * 100) : 0;

        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);

        if(burnAmount > 0) {
            if(_balances[address(this)] > burnAmount) {
                numberBurns = numberBurns + 1;
                burnedInfo[sender] = burnedInfo[sender] + burnAmount;
                totalBurned = totalBurned + burnAmount;

                _basicTransfer(address(this), burnTo, burnAmount);
                emit Burn(sender, burnAmount);
            }
        }

        return amount.sub(feeAmount).sub(burnAmount);
    }

    function shouldSwapBack() internal view returns (bool) {
        return msg.sender != pair
        && !inSwap
        && swapEnabled
        && _balances[address(this)] >= swapThreshold;
    }

    function clearStuckBalance() external {
        uint256 amountAVAX = address(this).balance;
        payable(marketingFeeReceiver).transfer(amountAVAX);
    }

    function enableTrading() public onlyOwner {
        tradingOpen = true;
    }

    function swapBack() internal swapping {
        uint256 dynamicLiquidityFee = liquidityFee;
        uint256 amountToLiquify = swapThreshold.mul(dynamicLiquidityFee).div(totalFee).div(2);
        uint256 amountToSwap = swapThreshold.sub(amountToLiquify);

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WAVAX();

        uint256 balanceBefore = address(this).balance;

        router.swapExactTokensForAVAXSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amountAVAX = address(this).balance.sub(balanceBefore);

        uint256 totalAVAXFee = totalFee.sub(dynamicLiquidityFee.div(2));
        uint256 amountAVAXLiquidity = amountAVAX.mul(dynamicLiquidityFee).div(totalAVAXFee).div(2);
        uint256 amountAVAXMarketing = amountAVAX.mul(marketingFee).div(totalAVAXFee);

        (bool tmpSuccess,) = payable(marketingFeeReceiver).call{value: amountAVAXMarketing, gas: 30000}("");
        
        tmpSuccess = false;

        if(amountToLiquify > 0){
            router.addLiquidityAVAX{value: amountAVAXLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                autoLiquidityReceiver,
                block.timestamp
            );
            emit AutoLiquify(amountAVAXLiquidity, amountToLiquify);
        }
    }

    function setTxLimit(uint256 amount) external onlyOwner() {
        _maxTxAmount = amount;
    }

    function setIsMaxExempt(address holder, bool exempt) external onlyOwner() {
        isMaxExempt[holder] = exempt;
    }

    function setIsFeeExempt(address holder, bool exempt) external onlyOwner() {
        isFeeExempt[holder] = exempt;
    }

    function setIsTxLimitExempt(address holder, bool exempt) external onlyOwner() {
        isTxLimitExempt[holder] = exempt;
    }

    function setFees(uint256 _liquidityFee, uint256 _marketingFee, uint256 _feeDenominator) external onlyOwner() {
        liquidityFee = _liquidityFee;
        marketingFee = _marketingFee;
        totalFee = _liquidityFee.add(_marketingFee);
        feeDenominator = _feeDenominator;
    }

    function setBuyFee(uint256 _buyFee) external onlyOwner() {
        buyFee = _buyFee;
    }

    function setMarketingWallet(address _mw) external onlyOwner() {
        marketingFeeReceiver = _mw;
    }

    function setSwapBackSettings(bool _enabled, uint256 _amount) external onlyOwner() {
        swapEnabled = _enabled;
        swapThreshold = _amount;
    }

    function removeLimits() external onlyOwner() {
        _maxTxAmount = _totalSupply;
        _maxWalletToken = _totalSupply;
    }

/**************************************************
 * Burn Based items
 */
    function setBurnTo(address newBurnTo) external onlyOwner() {
        burnTo = newBurnTo;
    }

    function setBurnFees(
        uint256 newBuyBurnFee, 
        uint256 newSellBurnFee
    ) external onlyOwner() {
        buyBurnFee = newBuyBurnFee;
        sellBurnFee = newSellBurnFee;
    }

    function setBuyBurnFee(uint256 newBuyBurnFee) external onlyOwner() {
        buyBurnFee = newBuyBurnFee;
    }

    function setSellBurnFee(uint256 newSellBurnFee) external onlyOwner() {
        sellBurnFee = newSellBurnFee;
    }

    function getBurnInfo(address wallet) external view returns (uint256) {
        return burnedInfo[wallet];
    }

    function getMyBurnInfo() external view returns (uint256) {
        return burnedInfo[msg.sender];
    }

    function getTotalBurned() external view returns (uint256) {
        return totalBurned;
    }

    function getNumberBurns() external view returns (uint256) {
        return numberBurns;
    }

    
/*
 * Burn Based items
 **************************************************/

}
