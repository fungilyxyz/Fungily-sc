// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {IERC721Collection} from "./IERC721Collection.sol";
import {FungilyDrop} from "./ERC721Collection.sol";

/// @title FungilyCollectionFactory
/// @notice This contract is still under development and has been optimized for quick deployment only.
contract FungilyCollectionFactory {
    uint16 public platformSalesFeeBps;
    address public feeReceiver;
    address public admin;
    uint256 public platformMintFee;

    /**
     * @dev Constructor to initialize the factory with platform details.
     * @notice This contract is responsible for creating new ERC721 collections.
     * @param _initialFeeReceiver The address that will receive platform fees.
     * @param _initialPlatformMintFee The initial mint fee for the platform.
     * @param _initialPlatformSalesFeeBps The initial sales fee in basis points for
     * @notice the admin is the deployer of the contract and can manage platform settings.
     */
    constructor(address _initialFeeReceiver, uint256 _initialPlatformMintFee, uint16 _initialPlatformSalesFeeBps) {
        feeReceiver = _initialFeeReceiver;
        platformMintFee = _initialPlatformMintFee;
        platformSalesFeeBps = _initialPlatformSalesFeeBps;
        admin = msg.sender;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Not admin");
        _;
    }

    event CollectionCreated(address indexed creator, address collectionAddress);

    /**
     * @dev Creates a new ERC721 collection.
     * @notice This function allows the creation of a new collection with specified details.
     * @param _collection The collection details including name, symbol, baseURI, etc. see IERC721Collection.Collection
     * @param _publicMint The public mint phase details including start time, end time, price, etc. see IERC721Collection.PublicMint
     */
    function createCollection(
        IERC721Collection.Collection memory _collection,
        IERC721Collection.PublicMint memory _publicMint
    ) external {
        IERC721Collection.Platform memory platform = IERC721Collection.Platform({
            feeReceipient: feeReceiver,
            mintFee: platformMintFee,
            salesFeeBps: platformSalesFeeBps
        });
        FungilyDrop collection = new FungilyDrop(_collection, _publicMint, platform);

        emit CollectionCreated(msg.sender, address(collection));
    }

    function setFeeReceiver(address _feeReceiver) external onlyAdmin {
        require(msg.sender == admin, "Not admin");
        feeReceiver = _feeReceiver;
    }

    function setAdmin(address _admin) external onlyAdmin {
        admin = _admin;
    }

    function setPlatformSalesFeBps(uint8 _newBps) external onlyAdmin {
        platformSalesFeeBps = _newBps;
    }

    function setPlatformMintFee(uint256 _newFee) external onlyAdmin {
        platformMintFee = _newFee;
    }
}
