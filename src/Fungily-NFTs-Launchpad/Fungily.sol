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
    /**
     * @dev Constructor to initialize the factory with platform details.
     * @notice This contract is responsible for creating new ERC721 collections.
     * @param _initialFeeReceiver The address that will receive platform fees.
     * @notice the admin is the deployer of the contract and can manage platform settings.
     */

    constructor(address _initialFeeReceiver) {
        feeReceiver = _initialFeeReceiver;
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
        FungilyDrop collection = new FungilyDrop(_collection, _publicMint, feeReceiver);

        emit CollectionCreated(msg.sender, address(collection));
    }

    function setFeeReceiver(address _feeReceiver) external onlyAdmin {
        require(msg.sender == admin, "Not admin");
        feeReceiver = _feeReceiver;
    }

    function setAdmin(address _admin) external onlyAdmin {
        admin = _admin;
    }
}
