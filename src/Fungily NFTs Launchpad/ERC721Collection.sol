// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {IERC721Collection} from "./IERC721Collection.sol";
import {IERC2981} from "@openzeppelin/interfaces/IERC2981.sol";
import {Ownable} from "@openzeppelin/access/Ownable.sol";
import {ERC721A} from "@ERC721A/ERC721A.sol";
import {IERC165} from "@openzeppelin/utils/introspection/ERC165.sol";
import {MerkleProof} from "@openzeppelin/utils/cryptography/MerkleProof.sol";
import {ReentrancyGuard} from "@openzeppelin/utils/ReentrancyGuard.sol";
import {BasisPointsCalculator} from "./BpsLib.sol";
import {ERC721URIStorage} from "@openzeppelin/token/ERC721/extensions/ERC721URIStorage.sol";

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
 * @title Fungily Launchpad.
 * @author (s) 0xstacker
 */
contract FungilyDrop is ERC721A, IERC721Collection, Ownable, ReentrancyGuard, IERC2981 {
    // Maximum number of presale phases that can be added.
    uint8 constant MAX_PRESALE_LIMIT = 5;

    // Maximum number of batch mints that can be done in a single transaction.
    uint8 constant BATCH_MINT_LIMIT = 8;

    // Fixed id for public mint phase
    uint8 constant PUBLIC_MINT_PHASE_ID = 0;

    // Sequential phase identities
    uint8 internal phaseIds;

    // Percentage paid to the platform by creator per nft sale
    uint16 internal immutable SALES_FEE_BPS;

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
    bool public tradingLocked;

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
    uint256 public immutable mintFee;

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
    PresalePhase[] public mintPhases;

    // Validate the existence of a phase.
    mapping(uint8 => bool) public phaseCheck;

    using MerkleProof for bytes32[];
    using BasisPointsCalculator for uint256;
    using BasisPointsCalculator for uint64;

    /**
     * @dev Initialize contract by setting necessary data.
     * @param _collection holds all collection related data. see {IERC721Collection-Collection}
     * @param _platform Holds all platform related data. see {IERC721Collection-Platform}
     * @param _publicMintConfig Is the public mint configuration for collection. see{IERC721Collection-PublicMint}
     */
    constructor(Collection memory _collection, PublicMint memory _publicMintConfig, Platform memory _platform)
        ERC721A(_collection.name, _collection.symbol)
        ReentrancyGuard()
        Ownable(_collection.owner)
    {
        // Configure collection
        maxSupply = _collection.maxSupply;

        _publicMint = _publicMintConfig;
        if (_collection.royaltyReceipient == address(0)) {
            royaltyFeeReceiver = _collection.owner;
        }
        if (_collection.proceedCollector == address(0)) {
            proceedCollector = _collection.owner;
        }
        if (!_collection.revealed) {
            revealed = false;
        }
        baseURI = _collection.baseURI;
        royaltyFeeBps = _collection.royaltyFeeBps;
        tradingLocked = _collection.tradingLocked;
        liquidityNftBps = _collection.liquidityNftBps;
        liquidityTokenBps = _collection.liquidityTokenBps;
        // Configure platform
        if (_platform.feeReceipient == address(0)) {
            revert ZeroAddress();
        }
        SALES_FEE_BPS = _platform.salesFeeBps;
        PLATFORM_FEE_RECEIPIENT = _platform.feeReceipient;
        mintFee = _platform.mintFee;
        absMaxSupply = maxSupply - (maxSupply.calculatePercentage(liquidityNftBps));
        liquidityNftQuantity = maxSupply - absMaxSupply;
    }

    receive() external payable {}

    fallback() external payable {}

    ///////////////////////// MODIFIERS ////////////////////////////////////

    // Enforce token owner priviledges
    modifier tokenOwner(uint256 tokenId) {
        address _owner = ownerOf(tokenId);
        if (_owner != _msgSenderERC721A()) {
            revert NotOwner(tokenId);
        }
        _;
    }

    // Block minting unless phase is active
    modifier phaseActive(MintPhase _phase, uint8 _phaseId) {
        if (_phase == MintPhase.PUBLIC) {
            require(
                _publicMint.startTime <= block.timestamp && block.timestamp <= _publicMint.endTime, "Phase Inactive"
            );
        } else {
            uint256 phaseStartTime = mintPhases[_phaseId].startTime;
            uint256 phaseEndTime = mintPhases[_phaseId].endTime;
            require(phaseStartTime <= block.timestamp && block.timestamp < phaseEndTime, "Phase Inactive");
        }
        _;
    }

    modifier verifyPhaseId(uint8 _phaseId) {
        if (_phaseId >= MAX_PRESALE_LIMIT) {
            revert InvalidPhase(_phaseId);
        }
        _;
    }

    // Allows owner to pause minting at any phase.
    modifier isPaused() {
        if (paused) {
            revert SaleIsPaused();
        }
        _;
    }

    /**
     * @dev Enforce phase minting limit per address.
     */
    modifier limit(MintPhase _phase, address _to, uint256 _amount, uint8 _phaseId) {
        if (_phase == MintPhase.PUBLIC) {
            uint8 publicMintLimit = _publicMint.maxPerWallet;
            if (balanceOf(_to) + _amount > publicMintLimit) {
                revert PhaseLimitExceeded(publicMintLimit);
            }
        } else {
            uint8 phaseLimit = mintPhases[_phaseId].maxPerAddress;
            if (balanceOf(_to) + _amount > phaseLimit) {
                revert PhaseLimitExceeded(phaseLimit);
            }
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

    /// @dev see {IERC721Collection-mintPublic}
    function mintPublic(uint256 _amount, address _to)
        external
        payable
        phaseActive(MintPhase.PUBLIC, PUBLIC_MINT_PHASE_ID)
        limit(MintPhase.PUBLIC, _to, _amount, PUBLIC_MINT_PHASE_ID)
        isPaused
        nonReentrant
    {
        if (!_canMint(_amount)) {
            revert SoldOut(maxSupply);
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
    function whitelistMint(bytes32[] memory _proof, uint8 _amount, uint8 _phaseId)
        external
        payable
        phaseActive(MintPhase.PRESALE, _phaseId)
        limit(MintPhase.PRESALE, _msgSender(), _amount, _phaseId)
        nonReentrant
        isPaused
    {
        if (!phaseCheck[_phaseId]) {
            revert InvalidPhase(_phaseId);
        }
        if (!_canMint(_amount)) {
            revert SoldOut(maxSupply);
        }
        uint256 totalCost = _getCost(MintPhase.PRESALE, _phaseId, _amount);
        if (msg.value < totalCost) {
            revert InsufficientFunds(totalCost);
        }
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(_msgSender()))));
        bool whitelisted = _proof.verify(mintPhases[_phaseId].merkleRoot, leaf);
        if (!whitelisted) {
            revert NotWhitelisted(_msgSender());
        }
        _mintNft(_msgSender(), _amount);
        _payout(MintPhase.PRESALE, _amount, _phaseId);
    }

    /////////////////////// ADMIN/CREATOR MINTING FUNCTIONS /////////////////////////

    /// @dev see {IERC721Collection-airdrop}
    function airdrop(address _to, uint256 _amount) external onlyOwner {
        if (!_canMint(_amount)) {
            revert SoldOut(maxSupply);
        }
        _mintNft(_to, _amount);
        emit Airdrop(_to, _amount);
    }

    ///@dev see {IERC721Collection-batchAirdrop}
    function batchAirdrop(address[] calldata _receipients, uint256 _amountPerAddress) external onlyOwner {
        if (_receipients.length > BATCH_MINT_LIMIT) {
            revert AmountTooHigh();
        }

        uint256 totalAmount = _amountPerAddress * _receipients.length;
        if (!_canMint(totalAmount)) {
            revert SoldOut(maxSupply);
        }
        for (uint256 i; i < _receipients.length; i++) {
            _mintNft(_receipients[i], _amountPerAddress);
        }
        emit BatchAirdrop(_receipients, _amountPerAddress);
    }

    //////////////////////////// PRESALE CONTROL /////////////////////////////////////

    /// @dev see {IERC721Collection-addPresalePhase}
    function addPresalePhase(PresalePhaseIn calldata _phase) external onlyOwner {
        if (mintPhases.length == MAX_PRESALE_LIMIT) {
            revert MaxPresaleLimitReached(MAX_PRESALE_LIMIT);
        }
        PresalePhase memory phase = PresalePhase({
            name: _phase.name,
            startTime: block.timestamp + _phase.startTime,
            endTime: block.timestamp + _phase.endTime,
            maxPerAddress: _phase.maxPerAddress,
            price: _phase.price,
            merkleRoot: _phase.merkleRoot,
            phaseId: phaseIds
        });

        mintPhases.push(phase);
        phaseCheck[phase.phaseId] = true;
        phaseIds += 1;
        emit AddPresalePhase(_phase.name, phase.phaseId);
    }

    /**
     * @dev Change the configuration for an added presale phase.
     * @param _phaseId is the phase to change config.
     * @param _newConfig is the configuration of the new phase.
     * Adds phase if phase does not exist and _phaseId does not exceed max allowed phase.
     *
     */
    function editPresalePhaseConfig(uint8 _phaseId, PresalePhaseIn memory _newConfig)
        external
        verifyPhaseId(_phaseId)
        onlyOwner
    {
        PresalePhase memory oldPhase = mintPhases[_phaseId];
        PresalePhase memory newPhase = PresalePhase({
            name: _newConfig.name,
            startTime: block.timestamp + _newConfig.startTime,
            endTime: block.timestamp + _newConfig.endTime,
            maxPerAddress: _newConfig.maxPerAddress,
            price: _newConfig.price,
            merkleRoot: _newConfig.merkleRoot,
            phaseId: _phaseId
        });
        if (phaseCheck[_phaseId]) {
            mintPhases[_phaseId] = newPhase;
        } else {
            mintPhases.push(newPhase);
            phaseCheck[_phaseId] = true;
        }
        emit EditPresaleConfig(oldPhase, newPhase);
    }

    /// @dev see {IERC721Collection-removePresalePhase}
    function removePresalePhase(uint8 _phaseId) external verifyPhaseId(_phaseId) onlyOwner {
        require(mintPhases[_phaseId].startTime > block.timestamp, "Phase Live");
        PresalePhase[] memory oldList = mintPhases;
        uint256 totalItems = oldList.length;
        phaseCheck[_phaseId] = false;
        delete mintPhases;
        for (uint8 i; i < totalItems; i++) {
            if (i < _phaseId) {
                mintPhases.push(oldList[i]);
            } else if (i > _phaseId) {
                uint8 newId = i - 1;
                oldList[i].phaseId = newId;
                mintPhases.push(oldList[i]);
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

    function endSale() external onlyOwner {
        // adjust supply if not minted out
        if (totalMinted() != absMaxSupply) {
            maxSupply = (totalMinted() * 10_000) / (10_000 - liquidityNftBps);
            liquidityNftQuantity = maxSupply - absMaxSupply;
            _deployLiquidity();
        } else {
            _deployLiquidity();
        }
    }

    ////////////////////////////////////////////////////////////////////////

    function _deployLiquidity() internal {
        // Liquidity deployment function of AMM would be called here.
    }

    // Withdraw funds from contract
    function withdraw(uint256 _amount) external onlyOwner nonReentrant {
        if (address(this).balance < _amount) {
            revert InsufficientFunds(_amount);
        }
        (bool success,) = payable(owner()).call{value: _amount}("");
        if (!success) {
            revert WithdrawalFailed();
        }
        emit WithdrawFunds(_amount);
    }

    /**
     * @dev Allows creator to change royalty info.
     * @param receiver is the address of the new royalty fee receiver.
     * @param _royaltyFeeBps is the new royalty fee bps| 100bps= 1%
     */
    function setRoyaltyInfo(address receiver, uint16 _royaltyFeeBps) external onlyOwner {
        if (receiver == address(0)) {
            revert InvalidRoyaltyConfig(receiver, _royaltyFeeBps);
        }
        if (_royaltyFeeBps > MAX_ROYALTY_FEE) {
            revert InvalidRoyaltyConfig(receiver, _royaltyFeeBps);
        }
        royaltyFeeReceiver = receiver;
        royaltyFeeBps = _royaltyFeeBps;
    }

    /// @notice Allows creator to permit trading of nfts on secondary marketplaces.
    function unlockTrading() external onlyOwner {
        tradingLocked = false;
    }

    /// @dev sets the base URI of the collection to the original as defined by creator.
    function reveal(string memory _originalURI) external onlyOwner {
        revealed = true;
        _setBaseURI(_originalURI);
    }

    /// @dev see {ERC721-_burn}
    function burn(uint256 tokenId_) external tokenOwner(tokenId_) {
        _burn(tokenId_);
    }

    /////////////////////////////// GENERAL GETTERS //////////////////////////////////////

    /**
     * @dev getter for presale phase data
     * @return array containing presale configuration for each added phase.
     */
    function getPresaleConfig() external view returns (PresalePhase[] memory) {
        return mintPhases;
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
        return (royaltyFeeReceiver, salePrice.calculatePercentage(royaltyFeeBps));
    }

    /**
     * @dev Calculates the share of the platform and creator from a minted token.
     * @param _phase is the mint phase of the token || Public or Presale.
     * @param _amount is the amount of tokens minted.
     * @param _phaseId is the phase id of the mint phase if it was minted on presale
     * @param _payee The party to be paid || Platform or Creator.
     * @return share of the platform or creator.
     * @notice The Platform share is calculated as the sum of mint fee for the amount of tokens minted and sales fee on each token.
     */
    function computeShare(MintPhase _phase, uint256 _amount, uint8 _phaseId, Payees _payee)
        public
        view
        returns (uint256 share)
    {
        if (_payee == Payees.PLATFORM) {
            if (_phase == MintPhase.PUBLIC) {
                uint256 _mintFee = mintFee * _amount;
                uint256 value = _publicMint.price * _amount;
                uint256 _salesFee = value.calculatePercentage(SALES_FEE_BPS);
                share = _mintFee + _salesFee;
            } else {
                uint256 _mintFee = mintFee * _amount;
                uint256 _price = mintPhases[_phaseId].price;
                uint256 value = _price * _amount;
                uint256 _salesFee = value.calculatePercentage(SALES_FEE_BPS);
                share = _mintFee + _salesFee;
            }
        } else {
            if (_phase == MintPhase.PUBLIC) {
                uint256 value = _publicMint.price * _amount;
                uint256 _salesFee = value.calculatePercentage(SALES_FEE_BPS);
                share = value - _salesFee;
            } else {
                uint256 _price = mintPhases[_phaseId].price;
                uint256 value = _price * _amount;
                uint256 _salesFee = value.calculatePercentage(SALES_FEE_BPS);
                share = value - _salesFee;
            }
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

    /// @return total nft minted
    function totalMinted() public view returns (uint256) {
        return _totalMinted();
    }

    function totalBurned() public view returns (uint256) {
        return _totalBurned();
    }

    ///////////////////////////////// TRANSFER CONTROL ////////////////////////////////////
    /**
     * @dev see {ERC721-safeTransferFrom}
     */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data)
        public
        payable
        override
        canTradeToken
    {
        super.safeTransferFrom(from, to, tokenId, _data);
    }

    /// @dev see {ERC721-transferFrom}
    function transferFrom(address from, address to, uint256 tokenId) public payable override canTradeToken {
        super.transferFrom(from, to, tokenId);
    }

    /// @dev see {IERC165-supportsInterface}
    function supportsInterface(bytes4 interfaceId) public view override(IERC165, ERC721A) returns (bool) {
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

    function _setBaseURI(string memory _uri) internal {
        baseURI = _uri;
    }

    ///@dev see {ERC721-_baseURI}
    function _baseURI() internal view override returns (string memory) {
        return baseURI;
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
        uint256 platformShare = computeShare(_phase, _amount, 0, Payees.PLATFORM);
        uint256 creatorShare = computeShare(_phase, _amount, _phaseId, Payees.CREATOR);
        (bool payPlatform,) = payable(platform).call{value: platformShare}("");
        if (!payPlatform) {
            revert PurchaseFailed();
        }
        (bool payCreator,) = payable(proceedCollector).call{value: creatorShare}("");
        if (!payCreator) {
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
