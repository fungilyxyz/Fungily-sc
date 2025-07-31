# FungilyCollectionFactory
[Git Source](https://github.com/fungilyxyz/Fungily-sc/blob/7747b2c98c7f286c31767f1054d8cd364f24a13f/src/Fungily-NFTs-Launchpad/Fungily.sol)

This contract is still under development and has been optimized for quick deployment only.


## State Variables
### platformSalesFeeBps

```solidity
uint16 public platformSalesFeeBps;
```


### feeReceiver

```solidity
address public feeReceiver;
```


### admin

```solidity
address public admin;
```


### platformMintFee

```solidity
uint256 public platformMintFee;
```


## Functions
### constructor

This contract is responsible for creating new ERC721 collections.

the admin is the deployer of the contract and can manage platform settings.

*Constructor to initialize the factory with platform details.*


```solidity
constructor(address _initialFeeReceiver, uint256 _initialPlatformMintFee, uint16 _initialPlatformSalesFeeBps);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_initialFeeReceiver`|`address`|The address that will receive platform fees.|
|`_initialPlatformMintFee`|`uint256`|The initial mint fee for the platform.|
|`_initialPlatformSalesFeeBps`|`uint16`|The initial sales fee in basis points for|


### onlyAdmin


```solidity
modifier onlyAdmin();
```

### createCollection

This function allows the creation of a new collection with specified details.

*Creates a new ERC721 collection.*


```solidity
function createCollection(
    IERC721Collection.Collection memory _collection,
    IERC721Collection.PublicMint memory _publicMint
) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_collection`|`IERC721Collection.Collection`|The collection details including name, symbol, baseURI, etc. see IERC721Collection.Collection|
|`_publicMint`|`IERC721Collection.PublicMint`|The public mint phase details including start time, end time, price, etc. see IERC721Collection.PublicMint|


### setFeeReceiver


```solidity
function setFeeReceiver(address _feeReceiver) external onlyAdmin;
```

### setAdmin


```solidity
function setAdmin(address _admin) external onlyAdmin;
```

### setPlatformSalesFeBps


```solidity
function setPlatformSalesFeBps(uint8 _newBps) external onlyAdmin;
```

### setPlatformMintFee


```solidity
function setPlatformMintFee(uint256 _newFee) external onlyAdmin;
```

## Events
### CollectionCreated

```solidity
event CollectionCreated(address indexed creator, address collectionAddress);
```

