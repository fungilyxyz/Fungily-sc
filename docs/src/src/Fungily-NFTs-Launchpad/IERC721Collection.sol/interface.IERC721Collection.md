# IERC721Collection
[Git Source](https://github.com/fungilyxyz/Fungily-sc/blob/87f757e4a1000c6a20733139de235f69e9558380/src/Fungily-NFTs-Launchpad/IERC721Collection.sol)


## Functions
### mintPublic

can only mint when public sale has started and the minting process is not paused by the creator.

minting is limited to the maximum amounts allowed on the public mint phase.

*Public minting function.*


```solidity
function mintPublic(uint256 _amount, address _to) external payable;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_amount`|`uint256`|is the amount of nfts to mint.|
|`_to`|`address`|is the address to mint the tokens to.|


### addPresalePhase

phases are identified sequentially using numbers, starting from 1.

*adds new presale phase for contract*


```solidity
function addPresalePhase(PresalePhaseIn calldata _phase) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_phase`|`PresalePhaseIn`|is the new phase to be added|


### removePresalePhase

Only possible if phase is not already live.

*Remove a presale phase from the collection.*


```solidity
function removePresalePhase(uint8 _phaseId) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_phaseId`|`uint8`|is the phase to be removed.|


### getPresaleConfig

*Returns an array containing details for each presale phase*


```solidity
function getPresaleConfig() external view returns (PresalePhase[] memory);
```

### whitelistMint

If phase is not active, function reverts.

If amount exceeds the phase limit, function reverts.

*Check the whitelist status of an account based on merkle proof.*


```solidity
function whitelistMint(bytes32[] memory _proof, uint8 _amount, uint8 _phaseId) external payable;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_proof`|`bytes32[]`|is a merkle proof to check for verification.|
|`_amount`|`uint8`|is the amount of tokens to be minted.|
|`_phaseId`|`uint8`|is the presale phase the user is attempting to mint for.|


## Events
### AddPresalePhase
*Emitted after adding a new presale phase to the collection.*


```solidity
event AddPresalePhase(string _phaseName, uint8 _phaseId);
```

### BatchAirdrop
*Emitted after a successful batch Airdrop.*


```solidity
event BatchAirdrop(address[] _receipients, uint256 _amount);
```

### Purchase
*Emitted after a successful Purchase.*


```solidity
event Purchase(address indexed _buyer, uint256 _amount);
```

### Airdrop
*Emitted after a successful Airdrop.*


```solidity
event Airdrop(address indexed _to, uint256 _amount);
```

### WithdrawFunds
*Emitted after funds are withdrawn from contract.*


```solidity
event WithdrawFunds(uint256 _amount);
```

### SetPhase
*Emitted after setting presale Phase.*


```solidity
event SetPhase(uint256 _phaseCount);
```

### SupplyReduced
*Emitted when the collection supply is reduced.*


```solidity
event SupplyReduced(uint64 _newSupply);
```

### ResumeSale
*Emitted when the sale is resumed.*


```solidity
event ResumeSale();
```

### SalePaused
*Emitted when the sale is paused.*


```solidity
event SalePaused();
```

### EditPresaleConfig
*Emitted when the configuration of a presale phase is changed.*


```solidity
event EditPresaleConfig(PresalePhase _oldConfig, PresalePhase _newConfig);
```

### RemovePresalePhase
*Emitted when creator removes a presale phase.*


```solidity
event RemovePresalePhase(uint8 _phaseId, string _name);
```

### LiquidityDeployed
*Emitted when liquidity is deployed.*


```solidity
event LiquidityDeployed(address indexed _pool, uint256 _liquidityNftSupply, uint256 _tokenLiquidityAmount);
```

## Errors
### NotWhitelisted
*Thrown when a user is not whitelisted for a presale phase*


```solidity
error NotWhitelisted(address _address);
```

### TradingLocked
*Thrown when a user tries to trade an NFT while collection is not sold out yet.*


```solidity
error TradingLocked();
```

### InsufficientFunds
*Thrown when a user does not send enough ether to mint an amount of NFTs*


```solidity
error InsufficientFunds(uint256 _cost);
```

### InvalidPhase
*Thrown when a user tries to mint from a phase that is not in the mint configuration*


```solidity
error InvalidPhase(uint8 _phaseId);
```

### PhaseLimitExceeded
*Thrown when a user tries to mint more than the amount they're allowed to mint from a particular phase.*


```solidity
error PhaseLimitExceeded(uint8 _phaseLimit);
```

### MaxPresaleLimitReached
*Thrown when creator tries to add more presale phase than permitted.*


```solidity
error MaxPresaleLimitReached(uint8 _maxLimit);
```

### NoReservedNfts
*Thrown when user tries to claim reserved NFTs but there are no reserved NFTs for the user.*


```solidity
error NoReservedNfts();
```

### PurchaseFailed
*Thrown whenever a purchase is attempted and fails.*


```solidity
error PurchaseFailed();
```

### InvalidLiquiditySupply
*Thrown when set liquidity supply is less than 1 NFT.*


```solidity
error InvalidLiquiditySupply(uint256 liquidityNftBps);
```

### CannotMintAmount
*Thrown when a user tries to mint an amount of NFTs that exceeds the maximum allowed.*


```solidity
error CannotMintAmount(uint256 _amount, uint256 _absMaxSupply);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_amount`|`uint256`|is the amount of NFTs to be minted.|
|`_absMaxSupply`|`uint256`|is the absolute maximum supply of the collection i.e part of the supply that is externally mintable by users.|

### PhaseInactive
*Thrown wheneve a mint is attempted on an inactive phase*


```solidity
error PhaseInactive();
```

### NotOwner
*Thrown when a user tries to execute a function that is only allowed to be called by the nft token owner.*


```solidity
error NotOwner(uint256 _tokenId);
```

### SaleIsPaused
*Thrown whenever a mint is attempted while sale is paused.*


```solidity
error SaleIsPaused();
```

### WithdrawalFailed
*Thrown when creator attempts to withdraw funds from the contract and the withdrawal fails.*


```solidity
error WithdrawalFailed();
```

### AmountTooHigh
*Thrown when creator tries to airdrop a set number of people and the number exceeds the allowed limit.*


```solidity
error AmountTooHigh();
```

### InvalidRoyaltyConfig
*Thrown when creator tries to set royalty receipient to an invalid address or to a value greater than allowed.*


```solidity
error InvalidRoyaltyConfig(address receiver, uint256 _royaltyFeeBps);
```

### InvalidLiquidityNftBps
*Thrown when creator tries to set liquidity NFT BPS to a value greater than allowed.*


```solidity
error InvalidLiquidityNftBps(uint256 _liquidityNftBps);
```

### InvalidLiquidityTokenBps
*Thrown when creator tries to set liquidity token BPS to a value greater than allowed.*


```solidity
error InvalidLiquidityTokenBps(uint256 _liquidityTokenBps);
```

### ZeroAddress
*Thrown when action is attempted on zero address*


```solidity
error ZeroAddress();
```

### LiquidityDeploymentFailed
*Thrown when liquidity deployment fails.*


```solidity
error LiquidityDeploymentFailed();
```

## Structs
### Collection
*Collection details*


```solidity
struct Collection {
    bool revealed;
    uint16 royaltyFeeBps;
    uint16 liquidityNftBps;
    uint16 liquidityTokenBps;
    address creator;
    uint64 maxSupply;
    string name;
    string symbol;
    string baseURI;
}
```

### PresalePhaseIn
*Holds the input data for presale configuration*


```solidity
struct PresalePhaseIn {
    uint8 maxPerAddress;
    string name;
    uint256 price;
    uint256 startTime;
    uint256 endTime;
    bytes32 merkleRoot;
}
```

### PublicMint
*Holds the details of the public/general mint phase*


```solidity
struct PublicMint {
    uint8 maxPerWallet;
    uint256 startTime;
    uint256 endTime;
    uint256 price;
}
```

### PresalePhase
*Holds the deta of a presale phase after it has been assigned an identifier*


```solidity
struct PresalePhase {
    uint8 maxPerAddress;
    uint8 phaseId;
    string name;
    uint256 price;
    uint256 startTime;
    uint256 endTime;
    bytes32 merkleRoot;
}
```

## Enums
### Payees
*Parties to be paid.*


```solidity
enum Payees {
    PLATFORM,
    CREATOR
}
```

### MintPhase

```solidity
enum MintPhase {
    PUBLIC,
    PRESALE
}
```

