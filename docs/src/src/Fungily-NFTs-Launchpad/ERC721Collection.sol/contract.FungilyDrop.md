# FungilyDrop
[Git Source](https://github.com/fungilyxyz/Fungily-sc/blob/7747b2c98c7f286c31767f1054d8cd364f24a13f/src/Fungily-NFTs-Launchpad/ERC721Collection.sol)

**Inherits:**
ERC721A, [IERC721Collection](/src/Fungily-NFTs-Launchpad/IERC721Collection.sol/interface.IERC721Collection.md), Ownable, ReentrancyGuard, IERC2981

**Author:**
(s) 0xstacker

This contract is still under development and has been optimized for quick deployment only.


## State Variables
### MAX_PRESALE_LIMIT

```solidity
uint8 constant MAX_PRESALE_LIMIT = 5;
```


### existingPhases

```solidity
uint8 existingPhases;
```


### BATCH_MINT_LIMIT

```solidity
uint8 constant BATCH_MINT_LIMIT = 8;
```


### PUBLIC_MINT_PHASE_ID

```solidity
uint8 constant PUBLIC_MINT_PHASE_ID = 0;
```


### phaseIds

```solidity
uint8 internal phaseIds;
```


### BASIS_POINT
*Basis point for percentage operations
100bps = 1%*


```solidity
uint16 BASIS_POINT = 10_000;
```


### MIN_LIQUIDITY_BPS

```solidity
uint16 constant MIN_LIQUIDITY_BPS = 1000;
```


### MAX_LIQUIDITY_BPS

```solidity
uint16 constant MAX_LIQUIDITY_BPS = 5000;
```


### SALES_FEE_BPS

```solidity
uint16 internal immutable SALES_FEE_BPS;
```


### royaltyFeeBps

```solidity
uint16 internal royaltyFeeBps;
```


### liquidityNftBps

```solidity
uint16 liquidityNftBps;
```


### liquidityTokenBps

```solidity
uint16 liquidityTokenBps;
```


### MAX_ROYALTY_FEE

```solidity
uint16 constant MAX_ROYALTY_FEE = 10_00;
```


### paused

```solidity
bool public paused;
```


### tradingLocked

```solidity
bool public tradingLocked = true;
```


### revealed
Set to false to conceal token URIs.

If set to false, token URIs will not be revealed until creator decides to reveal.

All token URIs will default to the baseURI which would hold the concealed metadata for the unreaveled collection

Original URI would be set during reveal

Once collection is revealed, It can no longer be concealed.


```solidity
bool public revealed = true;
```


### PLATFORM_FEE_RECEIPIENT

```solidity
address private immutable PLATFORM_FEE_RECEIPIENT;
```


### proceedCollector

```solidity
address proceedCollector;
```


### royaltyFeeReceiver

```solidity
address public royaltyFeeReceiver;
```


### baseURI

```solidity
string public baseURI;
```


### mintFee

```solidity
uint256 public immutable mintFee;
```


### maxSupply

```solidity
uint256 public maxSupply;
```


### absMaxSupply

```solidity
uint256 internal absMaxSupply;
```


### liquidityNftQuantity

```solidity
uint256 internal liquidityNftQuantity;
```


### _publicMint

```solidity
PublicMint private _publicMint;
```


### phaseData
Presale mint phases.
Maximum of 5 presale phases.


```solidity
PresalePhase[] public phaseData;
```


### mintPhases

```solidity
mapping(uint8 => PresalePhase) internal mintPhases;
```


### phaseCheck
*used to validate the existence of a phase.*


```solidity
mapping(uint8 => bool) public phaseCheck;
```


### reservedMints

```solidity
mapping(address => uint256 amount) private reservedMints;
```


## Functions
### constructor

*Initialize contract by setting necessary data.*


```solidity
constructor(Collection memory _collection, PublicMint memory _publicMintConfig, Platform memory _platform)
    ERC721A(_collection.name, _collection.symbol)
    ReentrancyGuard()
    Ownable(_collection.owner);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_collection`|`Collection`|holds all collection related data. see {IERC721Collection-Collection}|
|`_publicMintConfig`|`PublicMint`|Is the public mint configuration for collection. see{IERC721Collection-PublicMint}|
|`_platform`|`Platform`|Holds all platform related data. see {IERC721Collection-Platform}|


### receive


```solidity
receive() external payable;
```

### fallback


```solidity
fallback() external payable;
```

### isPaused


```solidity
modifier isPaused();
```

### canTradeToken

Prevents trading of tokens until unlocked by creator.

*Control token trading*


```solidity
modifier canTradeToken();
```

### mintPublic

*see {IERC721Collection-mintPublic}*


```solidity
function mintPublic(uint256 _amount, address _to) external payable nonReentrant;
```

### whitelistMint

*see {IERC721Collection-whitelistMint}*


```solidity
function whitelistMint(bytes32[] memory _proof, uint8 _amount, uint8 _phaseId) external payable nonReentrant;
```

### addPresalePhase

*see {IERC721Collection-addPresalePhase}*


```solidity
function addPresalePhase(PresalePhaseIn calldata _phase) external onlyOwner;
```

### removePresalePhase

*see {IERC721Collection-removePresalePhase}*


```solidity
function removePresalePhase(uint8 _phaseId) external onlyOwner;
```

### pauseSale


```solidity
function pauseSale() external onlyOwner;
```

### resumeSale


```solidity
function resumeSale() external onlyOwner;
```

### finalizeSale


```solidity
function finalizeSale(address _pool) external onlyOwner;
```

### _deployLiquidity


```solidity
function _deployLiquidity(address payable _pool, uint256 _liquidityNftSupply, uint256 _tokenLiquidityAmount) internal;
```

### withdraw


```solidity
function withdraw() internal onlyOwner;
```

### setRoyaltyInfo

*Allows creator to change royalty info.*


```solidity
function setRoyaltyInfo(address receiver, uint16 _royaltyFeeBps) external onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`receiver`|`address`|is the address of the new royalty fee receiver.|
|`_royaltyFeeBps`|`uint16`|is the new royalty fee bps| 100bps= 1%|


### unlockTrading

Allows creator to permit trading of nfts on secondary marketplaces.


```solidity
function unlockTrading() public onlyOwner;
```

### reveal

*sets the base URI of the collection to the original as defined by creator.*


```solidity
function reveal(string memory _originalURI) external onlyOwner;
```

### burn

*see [ERC721-_burn](/lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol/abstract.ERC20.md#_burn)*


```solidity
function burn(uint256 _tokenId) external;
```

### getPresaleConfig

*getter for presale phase data*


```solidity
function getPresaleConfig() external view returns (PresalePhase[] memory);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`PresalePhase[]`|array containing presale configuration for each added phase.|


### getMintableSupply

*getter for the externally mintable supply of the collection.*


```solidity
function getMintableSupply() external view returns (uint256);
```

### getPublicMintConfig

*getter for public mint data*


```solidity
function getPublicMintConfig() external view returns (PublicMint memory);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`PublicMint`|public mint configuration. see {IERC721Collection-PublicMint}|


### royaltyInfo

*See [IERC2981-royaltyInfo](/lib/openzeppelin-contracts/contracts/token/common/ERC2981.sol/abstract.ERC2981.md#royaltyinfo)*


```solidity
function royaltyInfo(uint256 tokenId, uint256 salePrice)
    external
    view
    returns (address receiver, uint256 royaltyAmount);
```

### computeShare

The Platform share is calculated as the sum of mint fee for the amount of tokens minted and sales fee on each token.
==========

*Calculates the share of the platform and creator from a minted token.*


```solidity
function computeShare(MintPhase _phase, uint256 _amount, uint8 _phaseId) public view returns (uint256 share);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_phase`|`MintPhase`|is the mint phase of the token || Public or Presale.|
|`_amount`|`uint256`|is the amount of tokens minted.|
|`_phaseId`|`uint8`|is the phase id of the mint phase if it was minted on presale|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`share`|`uint256`|as the share of the platform or creator from the amount of token minted.|


### tokenURI

If collection is unrevealed, base URI acts as concealer till collection is revealed.


```solidity
function tokenURI(uint256 tokenId) public view override returns (string memory uri);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`uri`|`string`|for tokenID|


### totalMinted


```solidity
function totalMinted() public view returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|totalMinted as the total number of tokens that have been minted|


### totalBurned


```solidity
function totalBurned() public view returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|totalBurned as the total number of tokens that have been burned|


### safeTransferFrom

*see [ERC721A-safeTransferFrom](/lib/openzeppelin-contracts/lib/forge-std/src/interfaces/IERC1155.sol/interface.IERC1155.md#safetransferfrom)*


```solidity
function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data)
    public
    payable
    override
    canTradeToken;
```

### transferFrom

*see [ERC721A-transferFrom](/lib/openzeppelin-contracts/lib/erc4626-tests/ERC4626.prop.sol/interface.IERC20.md#transferfrom)*


```solidity
function transferFrom(address from, address to, uint256 tokenId) public payable override canTradeToken;
```

### supportsInterface

*see [IERC165-supportsInterface](/lib/openzeppelin-contracts/lib/forge-std/src/interfaces/IERC165.sol/interface.IERC165.md#supportsinterface)*


```solidity
function supportsInterface(bytes4 interfaceId) public view override(IERC165, ERC721A) returns (bool);
```

### approve


```solidity
function approve(address to, uint256 tokenId) public payable override canTradeToken;
```

### setApprovalForAll


```solidity
function setApprovalForAll(address operator, bool approved) public override canTradeToken;
```

### _exceedsMintLimit

A limit of 0 means no mint restrictions.

*Enforce phase minting limit per address.*


```solidity
function _exceedsMintLimit(MintPhase _phase, address _to, uint256 _amount, uint8 _phaseId)
    internal
    view
    returns (bool limit);
```

### _verifyPhaseId


```solidity
function _verifyPhaseId(uint8 _phaseId) internal pure;
```

### _phaseActive


```solidity
function _phaseActive(MintPhase _phase, uint8 _phaseId) internal view returns (bool active);
```

### _setBaseURI


```solidity
function _setBaseURI(string memory _uri) internal;
```

### _baseURI

*see [ERC721-_baseURI](/lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol/abstract.ERC721.md#_baseuri)*


```solidity
function _baseURI() internal view override returns (string memory);
```

### _setLiquiditySupply


```solidity
function _setLiquiditySupply(uint16 _liquidityNftBps) internal;
```

### _canMint

Ensures that minting _amount tokens does not cause the total minted tokens to exceed max supply.

*Checks if a certain amount of token can be minted.*


```solidity
function _canMint(uint256 _amount) internal view returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_amount`|`uint256`|is the amount of tokens to be minted.|


### _startTokenId


```solidity
function _startTokenId() internal pure override returns (uint256);
```

### _getCost

*Compute the total cost of minting a certain amount of tokens at a certain mint phase*


```solidity
function _getCost(MintPhase _phase, uint8 _phaseId, uint256 _amount) public view returns (uint256 cost);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_phase`|`MintPhase`||
|`_phaseId`|`uint8`||
|`_amount`|`uint256`|is the amount of tokens to be minted.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`cost`|`uint256`|is the addition of sales price andf mint fee|


### _payout

*Payout platform fee*


```solidity
function _payout(MintPhase _phase, uint256 _amount, uint8 _phaseId) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_phase`|`MintPhase`||
|`_amount`|`uint256`|is the amount of nfts that was bought.|
|`_phaseId`|`uint8`|is the mint phase in which the nft was bought.|


### _mintNft

*Mint tokens to an address.*


```solidity
function _mintNft(address _to, uint256 _amount) internal isPaused;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_to`|`address`|is the address of the receipient.|
|`_amount`|`uint256`|is the amount of tokens to be minted.|


