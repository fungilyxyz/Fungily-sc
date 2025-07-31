// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {IERC721Collection} from "./IERC721Collection.sol";
import {FungilyDrop} from "./ERC721Collection.sol";

contract FungilyCollectionFactory {
    uint16 public platformSalesFeeBps;
    address public feeReceiver;
    address public admin;
    uint256 public platformMintFee;

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

    // Create a new ERC721 collection
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
