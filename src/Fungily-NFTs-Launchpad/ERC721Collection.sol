// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {IERC721Collection} from "./IERC721Collection.sol";
import {IERC2981} from "@openzeppelin/interfaces/IERC2981.sol";
import {Ownable} from "@openzeppelin/access/Ownable.sol";
import {ERC721A} from "@ERC721A/ERC721A.sol";
import {MerkleProof} from "@openzeppelin/utils/cryptography/MerkleProof.sol";
import {ReentrancyGuard} from "@openzeppelin/utils/ReentrancyGuard.sol";

/**
 * $$$$$$$$\                            $$\ $$\                 $$\                                              $$\                                 $$\
 * $$  _____|                           \__|$$ |                $$ |                                             $$ |                                $$ |
 * $$ |   $$\   $$\ $$$$$$$\   $$$$$$\  $$\ $$ |$$\   $$\       $$ |      $$$$$$\  $$\   $$\ $$$$$$$\   $$$$$$$\ $$$$$$$\   $$$$$$\   $$$$$$\   $$$$$$$ |
 * $$$$$\ $$ |  $$ |$$  __$$\ $$  __$$\ $$ |$$ |$$ |  $$ |      $$ |      \____$$\ $$ |  $$ |$$  __$$\ $$  _____|$$  __$$\ $$  __$$\  \____$$\ $$  __$$ |
 * $$  __|$$ |  $$ |$$ |  $$ |$$ /  $$ |$$ |$$ |$$ |  $$ |      $$ |      $$$$$$$ |$$ |  $$ |$$ |  $$ |$$ /      $$ |  $$ |$$ /  $$ | $$$$$$$ |$$ /  $$ |
 * $$ |   $$ |  $$ |$$ |  $$ |$$ |  $$ |$$ |$$ |$$ |  $$ |      $$ |     $$  __$$ |$$ |  $$ |$$ |  $$ |$$ |      $$ |  $$ |$$ |  $$ |$$  __$$ |$$ |  $$ |
 * $$ |   \$$$$$$  |$$ |  $$ |\$$$$$$$ |$$ |$$ |\$$$$$$$ |      $$$$$$$$\\$$$$$$$ |\$$$$$$  |$$ |  $$ |\$$$$$$$\ $$ |  $$ |$$$$$$$  |\$$$$$$$ |\$$$$$$$ |
 * \__|    \______/ \__|  \__| \____$$ |\__|\__| \____$$ |      \________|\_______| \______/ \__|  \__| \_______|\__|  \__|$$  ____/  \_______| \_______|
 *                            $$\   $$ |        $$\   $$ |                                                                 $$ |
 *                            \$$$$$$  |        \$$$$$$  |                                                                 $$ |
 *                             \______/          \______/                                                                  \__|
 */

/**
 * @title Fungily Liquid NFT Launchpad.
 * @author (s) 0xstacker
 * @notice This contract is still under development and has been optimized for quick deployment only.
 */
contract FungilyDrop is Ownable, ERC721A, IERC721Collection, ReentrancyGuard {
    // Maximum number of presale phases that can be added.
    uint8 constant MAX_PRESALE_LIMIT = 5;

    // Number of existing presale phases
    uint8 existingPhases;

    // Maximum number of batch mints that can be done in a single transaction.
    uint8 constant BATCH_MINT_LIMIT = 8;

    // Fixed id for public mint phase
    uint8 constant PUBLIC_MINT_PHASE_ID = 0;

    // Sequential phase identities.
    uint8 internal phaseIds;

    /**
     * @dev Basis point for percentage operations
     *  100bps = 1%
     */
    uint16 BASIS_POINT = 10_000;

    // Minimum percentage of NFTs to be set aside for AMM liquidity supply.
    uint16 constant MIN_LIQUIDITY_BPS = 1000; // 10%

    // Maximum percentage of NFTs to be set aside for AMM liquidity supply.
    uint16 constant MAX_LIQUIDITY_BPS = 5000; // 50%

    // Percentage paid to the platform by creator per nft sale
    uint16 internal constant SALES_FEE_BPS = 500; // 5%

    // Royalty fee bps. 100bps => 1%
    uint16 internal royaltyFeeBps;

    // Amount of NFTS % to set aside for AMM liquidity supply
    uint16 liquidityNftBps;

    // Amount of mint funds % to add to the AMM liquidity supply
    uint16 liquidityTokenBps;

    // Maximum allowed royalty fee: 10%
    uint16 constant MAX_ROYALTY_FEE = 10_00;

    // If set to true, pauses minting of tokens in all phases.
    bool public paused;

    // If set to true, prevents trading of tokens until minting is complete.
    bool public tradingLocked = true;

    /**
     * Set to false to conceal token URIs.
     * @notice If set to false, token URIs will not be revealed until creator decides to reveal.
     * @notice All token URIs will default to the baseURI which would hold the concealed metadata for the unreaveled collection
     * @notice Original URI would be set during reveal
     * @notice Once collection is revealed, It can no longer be concealed.
     */
    bool public revealed = true;

    // The address to which the platform fees are paid.
    address private immutable PLATFORM_FEE_RECEIPIENT;

    // The address to which Sale proceeds are paid. Defaults to owner address if not set on deployment.
    address proceedCollector;

    // The address to which Royalty is paid. defaults to owner address if not set on deployment.
    address public royaltyFeeReceiver;

    // Collection base URI
    string public baseURI;

    // Fee paid to the platform per nft minted by users.
    uint256 public constant mintFee = 0.0002 ether;

    // Maximum supply of collection
    uint256 public maxSupply;

    // Absolute maximum supply of the collection after removing liquidity percentage.
    uint256 internal absMaxSupply;

    // Amount of nfts that would be used for liquidity provision.
    uint256 internal liquidityNftQuantity;

    // Public mint configuration
    PublicMint private _publicMint;

    /**
     * Presale mint phases.
     * Maximum of 5 presale phases.
     */
    PresalePhase[] public phaseData;
    mapping(uint8 => PresalePhase) internal mintPhases;

    /// @dev used to validate the existence of a phase.
    mapping(uint8 => bool) public phaseCheck;

    using MerkleProof for bytes32[];

    /**
     * @dev Initialize contract by setting necessary data.
     * @param _collection holds all collection related data. see {IERC721Collection-Collection}
     * @param _publicMintConfig Is the public mint configuration for collection. see{IERC721Collection-PublicMint}
     */
    constructor(Collection memory _collection, PublicMint memory _publicMintConfig, address _platformFeeReceipient)
        ERC721A(_collection.name, _collection.symbol)
        ReentrancyGuard()
        Ownable(_collection.creator) // Set the owner to the deployer of the contract
    {
        // Configure collection
        maxSupply = _collection.maxSupply;

        _publicMint = _publicMintConfig;

        if (!_collection.revealed) {
            revealed = false;
        }

        baseURI = _collection.baseURI;
        royaltyFeeBps = _collection.royaltyFeeBps;
        liquidityNftBps = _collection.liquidityNftBps;
        liquidityTokenBps = _collection.liquidityTokenBps;
        // Configure platform
        PLATFORM_FEE_RECEIPIENT = _platformFeeReceipient;
        _setLiquiditySupply(_collection.liquidityNftBps);
    }

    receive() external payable {}

    fallback() external payable {}

    ///////////////////////// MODIFIERS ////////////////////////////////////

    // Allows owner to pause minting at any phase.
    modifier isPaused() {
        if (paused) {
            revert SaleIsPaused();
        }
        _;
    }

    /**
     * @dev Control token trading
     * @notice Prevents trading of tokens until unlocked by creator.
     */
    modifier canTradeToken() {
        if (tradingLocked) {
            revert TradingLocked();
        }
        _;
    }

    ///////////////////////// USER MINTING FUNCTIONS //////////////////////////////////

    mapping(address => uint256 amount) private reservedMints;

    /// @dev see {IERC721Collection-mintPublic}
    function mintPublic(uint256 _amount, address _to) external payable nonReentrant {
        if (_exceedsMintLimit(MintPhase.PUBLIC, _to, _amount, PUBLIC_MINT_PHASE_ID)) {
            revert PhaseLimitExceeded(_publicMint.maxPerWallet);
        }

        if (!_canMint(_amount)) {
            revert CannotMintAmount(_amount, absMaxSupply);
        }

        bool active = _phaseActive(MintPhase.PUBLIC, PUBLIC_MINT_PHASE_ID);
        if (!active) {
            revert PhaseInactive();
        }

        uint256 totalCost = _getCost(MintPhase.PUBLIC, PUBLIC_MINT_PHASE_ID, _amount);
        if (msg.value < totalCost) {
            revert InsufficientFunds(totalCost);
        }

        _mintNft(_to, _amount);
        _payout(MintPhase.PUBLIC, _amount, PUBLIC_MINT_PHASE_ID);
        emit Purchase(_to, _amount);
    }

    /**
     *
     * @dev see {IERC721Collection-whitelistMint}
     */
    function whitelistMint(bytes32[] memory _proof, uint8 _amount, uint8 _phaseId) external payable nonReentrant {
        if (!phaseCheck[_phaseId]) {
            revert InvalidPhase(_phaseId);
        }

        if (_exceedsMintLimit(MintPhase.PRESALE, _msgSender(), _amount, _phaseId)) {
            revert PhaseLimitExceeded(mintPhases[_phaseId].maxPerAddress);
        }

        if (!_canMint(_amount)) {
            revert CannotMintAmount(_amount, absMaxSupply);
        }
        bool active = _phaseActive(MintPhase.PRESALE, _phaseId);

        if (!active) {
            revert PhaseInactive();
        }

        uint256 totalCost = _getCost(MintPhase.PRESALE, _phaseId, _amount);
        if (msg.value < totalCost) {
            revert InsufficientFunds(totalCost);
        }
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(_msgSender()))));
        bool whitelisted = _proof.verify(mintPhases[_phaseId].merkleRoot, leaf);
        if (!whitelisted) {
            revert NotWhitelisted(_msgSenderERC721A());
        }
        _mintNft(_msgSenderERC721A(), _amount);
        _payout(MintPhase.PRESALE, _amount, _phaseId);
    }

    //////////////////////////// PRESALE CONTROL /////////////////////////////////////

    /// @dev see {IERC721Collection-addPresalePhase}
    function addPresalePhase(PresalePhaseIn calldata _phase) external onlyOwner {
        if (existingPhases == MAX_PRESALE_LIMIT) {
            revert MaxPresaleLimitReached(MAX_PRESALE_LIMIT);
        }
        phaseIds++;

        PresalePhase memory phase = PresalePhase({
            name: _phase.name,
            startTime: block.timestamp + _phase.startTime,
            endTime: block.timestamp + _phase.endTime,
            maxPerAddress: _phase.maxPerAddress,
            price: _phase.price,
            merkleRoot: _phase.merkleRoot,
            phaseId: phaseIds
        });

        mintPhases[phaseIds] = phase;
        phaseData.push(phase);
        phaseCheck[phase.phaseId] = true;
        existingPhases++;
        emit AddPresalePhase(_phase.name, phase.phaseId);
    }

    /// @dev see {IERC721Collection-removePresalePhase}

    function removePresalePhase(uint8 _phaseId) external onlyOwner {
        _verifyPhaseId(_phaseId);
        require(mintPhases[_phaseId].startTime > block.timestamp, "Phase Live");
        delete mintPhases[_phaseId];
        phaseCheck[_phaseId] = false;
        phaseIds--;
        existingPhases--;
        PresalePhase[] memory oldList = phaseData;
        uint256 totalItems = oldList.length;
        delete phaseData;
        _phaseId -= 1;
        for (uint8 i; i < totalItems; i++) {
            if (i < _phaseId) {
                phaseData.push(oldList[i]);
            } else if (i > _phaseId) {
                uint8 newId = i - 1;
                oldList[i].phaseId = newId;
                phaseData.push(oldList[i]);
            }
        }
    }

    ////////////////////// COLLECTION SALE CONTROL ///////////////////////////

    // Pause mint process
    function pauseSale() external onlyOwner {
        paused = true;
        emit SalePaused();
    }

    // Resume mint process
    function resumeSale() external onlyOwner {
        paused = false;
        emit ResumeSale();
    }

    ///////////////////////// SUPPLY CONTROL //////////////////////////////

    // total minted * 100 / percentage mintable
    // mints and sends nfts to a temporary vault address provided by creator for testing purposes.

    function finalizeSale(address _pool) external onlyOwner {
        uint256 tokenLiquidityAmount = (address(this).balance * liquidityTokenBps) / BASIS_POINT;
        // adjust supply if not minted out
        if (totalMinted() != absMaxSupply) {
            maxSupply = (totalMinted() * BASIS_POINT) / (BASIS_POINT - liquidityNftBps);
            _setLiquiditySupply(liquidityNftBps);
            // Liquidity NFTs would be minted at this level
            _deployLiquidity(payable(_pool), liquidityNftQuantity, tokenLiquidityAmount);
            unlockTrading();
            withdraw();
        } else {
            _deployLiquidity(payable(_pool), liquidityNftQuantity, tokenLiquidityAmount);
            unlockTrading();
            withdraw();
        }
    }

    ////////////////////////////////////////////////////////////////////////

    function _deployLiquidity(address payable _pool, uint256 _liquidityNftSupply, uint256 _tokenLiquidityAmount)
        internal
    {
        if (_pool == address(0)) {
            revert ZeroAddress();
        }
        _mintNft(_pool, _liquidityNftSupply);
        (bool success,) = _pool.call{value: _tokenLiquidityAmount}("");
        if (!success) {
            revert LiquidityDeploymentFailed();
        }
        emit LiquidityDeployed(_pool, _liquidityNftSupply, _tokenLiquidityAmount);
    }

    // Withdraw funds from contract
    function withdraw() internal onlyOwner {
        uint256 balance = address(this).balance;
        (bool success,) = payable(owner()).call{value: balance}("");
        if (!success) {
            revert WithdrawalFailed();
        }
        emit WithdrawFunds(balance);
    }

    /// @notice Allows creator to permit trading of nfts on secondary marketplaces.
    function unlockTrading() internal onlyOwner {
        tradingLocked = false;
    }

    /// @dev sets the base URI of the collection to the original as defined by creator.
    function reveal(string memory _originalURI) external onlyOwner {
        revealed = true;
        _setBaseURI(_originalURI);
    }

    /// @dev see {ERC721-_burn}
    function burn(uint256 _tokenId) external {
        if (ownerOf(_tokenId) != _msgSenderERC721A()) {
            revert NotOwner(_tokenId);
        }
        _burn(_tokenId);
    }

    /////////////////////////////// GENERAL GETTERS //////////////////////////////////////

    /**
     * @dev getter for presale phase data
     * @return array containing presale configuration for each added phase.
     */
    function getPresaleConfig() external view returns (PresalePhase[] memory) {
        return phaseData;
    }

    /**
     * @dev getter for the externally mintable supply of the collection.
     */
    function getMintableSupply() external view returns (uint256) {
        return absMaxSupply;
    }

    /**
     * @dev getter for public mint data
     * @return public mint configuration. see {IERC721Collection-PublicMint}
     */
    function getPublicMintConfig() external view returns (PublicMint memory) {
        return _publicMint;
    }

    /**
     * @dev See {IERC2981-royaltyInfo}
     */
    function royaltyInfo(uint256 tokenId, uint256 salePrice)
        external
        view
        returns (address receiver, uint256 royaltyAmount)
    {
        address _tokenOwner = ownerOf(tokenId);
        if (_tokenOwner == address(0)) {
            revert OwnerQueryForNonexistentToken();
        }
        return (owner(), (salePrice * royaltyFeeBps / BASIS_POINT));
    }

    /**
     * @dev Calculates the share of the platform and creator from a minted token.
     * @param _phase is the mint phase of the token || Public or Presale.
     * @param _amount is the amount of tokens minted.
     * @param _phaseId is the phase id of the mint phase if it was minted on presale
     * @return share as the share of the platform or creator from the amount of token minted.
     * @notice The Platform share is calculated as the sum of mint fee for the amount of tokens minted and sales fee on each token.
     *  ==========
     */
    function computeShare(MintPhase _phase, uint256 _amount, uint8 _phaseId) public view returns (uint256 share) {
        if (_phase == MintPhase.PUBLIC) {
            uint256 _mintFee = mintFee * _amount;
            uint256 value = _publicMint.price * _amount;
            uint256 _salesFee = (value * SALES_FEE_BPS) / BASIS_POINT;
            share = _mintFee + _salesFee;
        } else {
            uint256 _mintFee = mintFee * _amount;
            uint256 _price = mintPhases[_phaseId].price;
            uint256 value = _price * _amount;
            uint256 _salesFee = (value * SALES_FEE_BPS) / BASIS_POINT;
            share = _mintFee + _salesFee;
        }
    }

    /**
     * @return uri for tokenID
     *  @notice If collection is unrevealed, base URI acts as concealer till collection is revealed.
     */
    function tokenURI(uint256 tokenId) public view override returns (string memory uri) {
        if (!revealed) {
            return baseURI;
        }
        uri = super.tokenURI(tokenId);
    }

    /// @return totalMinted as the total number of tokens that have been minted
    function totalMinted() public view returns (uint256) {
        return _totalMinted();
    }

    /// @return totalBurned as the total number of tokens that have been burned
    function totalBurned() public view returns (uint256) {
        return _totalBurned();
    }

    ///////////////////////////////// TRANSFER CONTROL ////////////////////////////////////

    /// @dev see {ERC721A-safeTransferFrom}
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data)
        public
        payable
        override
        canTradeToken
    {
        super.safeTransferFrom(from, to, tokenId, _data);
    }

    /// @dev see {ERC721A-transferFrom}
    function transferFrom(address from, address to, uint256 tokenId) public payable override canTradeToken {
        super.transferFrom(from, to, tokenId);
    }

    /// @dev see {IERC165-supportsInterface}
    function supportsInterface(bytes4 interfaceId) public view override returns (bool) {
        return interfaceId == type(IERC2981).interfaceId || interfaceId == type(IERC721Collection).interfaceId
            || super.supportsInterface(interfaceId);
    }

    function approve(address to, uint256 tokenId) public payable override canTradeToken {
        super.approve(to, tokenId);
    }

    function setApprovalForAll(address operator, bool approved) public override canTradeToken {
        super.setApprovalForAll(operator, approved);
    }

    /////////////////////////////////////// INTERNALS ////////////////////////////////////////////////

    /**
     * @dev Enforce phase minting limit per address.
     * @notice A limit of 0 means no mint restrictions.
     */
    function _exceedsMintLimit(MintPhase _phase, address _to, uint256 _amount, uint8 _phaseId)
        internal
        view
        returns (bool limit)
    {
        if (_phase == MintPhase.PUBLIC) {
            uint8 publicMintLimit = _publicMint.maxPerWallet;
            limit = balanceOf(_to) + _amount > publicMintLimit && publicMintLimit != 0 ? true : false;
        } else {
            uint8 phaseLimit = mintPhases[_phaseId].maxPerAddress;
            limit = balanceOf(_to) + _amount > phaseLimit && phaseLimit != 0 ? true : false;
        }
    }

    // Ensures the total number of added minting phase does not exceed the maximum allowed
    function _verifyPhaseId(uint8 _phaseId) internal pure {
        if (_phaseId >= MAX_PRESALE_LIMIT) {
            revert InvalidPhase(_phaseId);
        }
    }

    // Block minting unless phase is active
    function _phaseActive(MintPhase _phase, uint8 _phaseId) internal view returns (bool active) {
        if (_phase == MintPhase.PUBLIC) {
            active = _publicMint.startTime >= block.timestamp || block.timestamp > _publicMint.endTime ? false : true;
        } else {
            uint256 phaseStartTime = mintPhases[_phaseId].startTime;
            uint256 phaseEndTime = mintPhases[_phaseId].endTime;
            active = phaseStartTime >= block.timestamp || block.timestamp > phaseEndTime ? false : true;
        }
    }

    function _setBaseURI(string memory _uri) internal {
        baseURI = _uri;
    }

    ///@dev see {ERC721-_baseURI}
    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    function _setLiquiditySupply(uint16 _liquidityNftBps) internal {
        if (_liquidityNftBps > MAX_LIQUIDITY_BPS || _liquidityNftBps < MIN_LIQUIDITY_BPS) {
            revert InvalidLiquiditySupply(_liquidityNftBps);
        }
        uint256 lqtySupply = (maxSupply * liquidityNftBps) / BASIS_POINT;
        absMaxSupply = maxSupply - lqtySupply;
        liquidityNftQuantity = maxSupply - absMaxSupply;
    }

    /**
     * @dev Checks if a certain amount of token can be minted.
     * @param _amount is the amount of tokens to be minted.
     * @notice Ensures that minting _amount tokens does not cause the total minted tokens to exceed max supply.
     */
    function _canMint(uint256 _amount) internal view returns (bool) {
        if (_totalMinted() + _amount > maxSupply) {
            return false;
        } else {
            return true;
        }
    }

    // Start token id for the collection.
    function _startTokenId() internal pure override returns (uint256) {
        return 1;
    }

    /**
     * @dev Compute the total cost of minting a certain amount of tokens at a certain mint phase
     * @param _amount is the amount of tokens to be minted.
     * @return cost is the addition of sales price andf mint fee
     */
    function _getCost(MintPhase _phase, uint8 _phaseId, uint256 _amount) public view returns (uint256 cost) {
        if (_phase == MintPhase.PUBLIC) {
            return (_publicMint.price * _amount) + (mintFee * _amount);
        } else {
            return (mintPhases[_phaseId].price * _amount) + (mintFee * _amount);
        }
    }

    /**
     *
     * @dev Payout platform fee
     * @param _amount is the amount of nfts that was bought.
     * @param _phaseId is the mint phase in which the nft was bought.
     */
    function _payout(MintPhase _phase, uint256 _amount, uint8 _phaseId) internal {
        address platform = PLATFORM_FEE_RECEIPIENT;
        uint256 platformShare = computeShare(_phase, _amount, _phaseId);
        (bool payPlatform,) = payable(platform).call{value: platformShare}("");
        if (!payPlatform) {
            revert PurchaseFailed();
        }
    }

    /**
     * @dev Mint tokens to an address.
     * @param _to is the address of the receipient.
     * @param _amount is the amount of tokens to be minted.
     */
    function _mintNft(address _to, uint256 _amount) internal isPaused {
        _safeMint(_to, _amount);
    }
}
