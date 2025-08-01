// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {FungilyDrop} from "../src/Fungily-NFTs-Launchpad/ERC721Collection.sol";
import {IERC721Collection} from "../src/Fungily-NFTs-Launchpad/IERC721Collection.sol";

contract ERC721CollectionTest is Test {
    FungilyDrop public collection;
    FungilyDrop public collection2;
    address creator = address(123);
    bool lockedTillMintOut = true;
    uint256 public singleMintCost = 110;
    uint256 publicMintLimit = 2;
    uint256 salePrice = 200;
    address platform = address(100);
    // IERC721Collection.Platform platform =
    //     IERC721Collection.Platform({salesFeeBps: 10_00, feeReceipient: address(234), mintFee: 10});

    bytes32[] proof = [
        bytes32(0xad67874866783b4129c60d23995daac0c837c320b38a19d1915e7fa4586bcefc),
        bytes32(0xf0718c9b19326d1812c0d459d3507b9122280148d3f90f4f3c97c0e6a9c946e5)
    ];

    IERC721Collection.PublicMint public publicMintConfig =
        IERC721Collection.PublicMint({maxPerWallet: 2, startTime: 0, endTime: 100, price: 100});

    IERC721Collection.PublicMint public publicMintConfig2 =
        IERC721Collection.PublicMint({maxPerWallet: 0, startTime: 0, endTime: 100, price: 100});

    IERC721Collection.PresalePhaseIn public presalePhaseConfig1 = IERC721Collection.PresalePhaseIn({
        maxPerAddress: 2,
        name: "Test Phase",
        price: 50,
        startTime: 0,
        endTime: 100,
        merkleRoot: bytes32(0x9c8ddc6ab231bcd108eb0758933a2bb40bc8dad8fbae0261383da40014080906)
    });

    IERC721Collection.PresalePhaseIn public presalePhaseConfig2 = IERC721Collection.PresalePhaseIn({
        maxPerAddress: 2,
        name: "Test Phase 2",
        price: 150,
        startTime: 10,
        endTime: 50,
        merkleRoot: bytes32(0x9c8ddc6ab231bcd108eb0758933a2bb40bc8dad8fbae0261383da40014080906)
    });

    IERC721Collection.Collection collectionConfig1 = IERC721Collection.Collection({
        revealed: false,
        maxSupply: 100,
        name: "Test Collection",
        creator: creator,
        symbol: "TST",
        baseURI: "https://example.com/",
        royaltyFeeBps: 500,
        liquidityNftBps: 1000,
        liquidityTokenBps: 500
    });

    function setUp() public {
        vm.startPrank(creator);
        collection = new FungilyDrop(collectionConfig1, publicMintConfig, platform);
        collection2 = new FungilyDrop(collectionConfig1, publicMintConfig2, platform);
        vm.stopPrank();

        console.log("owner", collection.owner());
    }

    function _getOldData(address _minter, FungilyDrop _collection)
        internal
        view
        returns (
            uint256 previousMinterNftBal,
            uint256 previousCreatorEthBal,
            uint256 previousPlatformEthBal,
            uint256 previousTotalMinted
        )
    {
        previousMinterNftBal = _collection.balanceOf(address(_minter));
        previousTotalMinted = _collection.totalMinted();
        previousCreatorEthBal = creator.balance;
        previousPlatformEthBal = platform.balance;
        console.log("Creator previous balance: ", previousCreatorEthBal);
        console.log("Platform previous balance: ", previousPlatformEthBal);
    }

    function _verifyOldDataWithNew(
        address _minter,
        uint256 _prevMinterNftBal,
        uint256 _amount,
        uint256 _prevCreatorEthBal,
        uint256 _prevPlatformEthBal,
        uint256 _prevTotalMinted,
        FungilyDrop _collection
    ) internal view {
        uint256 newMinterNftBal = _collection.balanceOf(_minter);
        uint256 newPlatformEthBal =
            _prevPlatformEthBal + _collection.computeShare(IERC721Collection.MintPhase.PUBLIC, _amount, 0);
        console.log("Platform new balance: ", newPlatformEthBal);
        assertEq(newMinterNftBal, _prevMinterNftBal + _amount);
        assertEq(_collection.totalMinted(), _prevTotalMinted + _amount);
        assertEq(creator.balance, _prevCreatorEthBal);
        assertEq(platform.balance, newPlatformEthBal);
    }

    function _mintPublic(FungilyDrop _collection, address _to, uint256 _amount, uint256 _value) internal {
        vm.prank(_to);
        _collection.mintPublic{value: _value}(_amount, address(_to));
    }

    function test_publicMint() public {
        address minter = address(456);
        deal(minter, 350);
        (
            uint256 previousMinterNftBal,
            uint256 previousCreatorEthBal,
            uint256 previousPlatformEthBal,
            uint256 previousTotalMinted
        ) = _getOldData(minter, collection);
        _mintPublic(collection, minter, 1, singleMintCost);
        _verifyOldDataWithNew(
            minter,
            previousMinterNftBal,
            1,
            previousCreatorEthBal,
            previousPlatformEthBal,
            previousTotalMinted,
            collection
        );
    }

    function testRevertpublicMintLimit() public {
        address minter = address(456);
        deal(minter, 350);
        vm.expectRevert();
        _mintPublic(collection, minter, 3, singleMintCost * 3);
    }

    function test_mintMultiple() public {
        address minter = address(456);
        deal(minter, 350);
        (
            uint256 previousMinterNftBal,
            uint256 previousCreatorEthBal,
            uint256 previousPlatformEthBal,
            uint256 previousTotalMinted
        ) = _getOldData(minter, collection);
        _mintPublic(collection, minter, 2, singleMintCost * 2);
        _verifyOldDataWithNew(
            minter,
            previousMinterNftBal,
            2,
            previousCreatorEthBal,
            previousPlatformEthBal,
            previousTotalMinted,
            collection
        );
    }

    function test_addPresale() public {
        uint256 startTimeInSec = 0;
        uint256 endTimeInSec = 100;
        vm.prank(creator);
        collection.addPresalePhase(presalePhaseConfig1);
        assertEq(collection.getPresaleConfig().length, 1);
        assertEq(collection.getPresaleConfig()[0].maxPerAddress, 2);
        assertEq(collection.getPresaleConfig()[0].name, "Test Phase");
        assertEq(collection.getPresaleConfig()[0].price, 50);
        assertEq(collection.getPresaleConfig()[0].startTime, block.timestamp + startTimeInSec);
        assertEq(collection.getPresaleConfig()[0].endTime, block.timestamp + endTimeInSec);
    }

    function testRevert_WhenPresaleLimitReached() public {
        uint256 startTimeInSec = 0;
        uint256 endTimeInSec = 100;
        IERC721Collection.PresalePhaseIn memory phase = IERC721Collection.PresalePhaseIn({
            maxPerAddress: 2,
            name: "Test Phase",
            price: 100,
            startTime: startTimeInSec,
            endTime: endTimeInSec,
            merkleRoot: bytes32(0)
        });
        vm.startPrank(creator);
        collection.addPresalePhase(phase);
        collection.addPresalePhase(phase);
        collection.addPresalePhase(phase);
        collection.addPresalePhase(phase);
        collection.addPresalePhase(phase);
        vm.expectRevert();
        collection.addPresalePhase(phase);
        vm.stopPrank();
    }

    function testRevert_MintWhilePaused() public {
        address minter = address(567);
        vm.prank(creator);
        collection.pauseSale();
        deal(minter, 350);
        vm.expectRevert();
        _mintPublic(collection, address(567), 2, singleMintCost * 2);
    }

    function testMintAfterResume() public {
        address minter = address(567);
        vm.startPrank(creator);
        collection.pauseSale();
        collection.resumeSale();
        vm.stopPrank();
        deal(minter, 350);
        _mintPublic(collection, address(567), 2, singleMintCost * 2);
    }

    function _mintWhitelist(address _to, uint8 _amount, uint8 _phaseId, uint256 _value) internal {
        vm.startPrank(_to);
        collection.whitelistMint{value: _value}(proof, _amount, _phaseId);
        vm.stopPrank();
    }

    function testWhitelistMint() public {
        address minter = address(345);
        vm.startPrank(creator);
        collection.addPresalePhase(presalePhaseConfig1);
        vm.stopPrank();
        deal(minter, 350);
        uint256 _startTime = collection.getPresaleConfig()[0].startTime;
        skip(_startTime);
        _mintWhitelist(minter, 1, 1, 70);
    }

    function testWhitelistMintMultiple() public {
        address minter = address(345);
        vm.startPrank(creator);
        collection.addPresalePhase(presalePhaseConfig1);
        vm.stopPrank();
        deal(minter, 350);
        uint256 _startTime = collection.getPresaleConfig()[0].startTime;
        skip(_startTime);
        _mintWhitelist(minter, 2, 1, 120);
    }

    function testRevertNonWhitelistedMinter() public {
        address minter = address(999);
        vm.startPrank(creator);
        collection.addPresalePhase(presalePhaseConfig1);
        vm.stopPrank();
        deal(minter, 350);
        uint256 _startTime = collection.getPresaleConfig()[0].startTime;
        skip(_startTime);
        vm.expectRevert();
        _mintWhitelist(minter, 1, 0, 70);
    }

    function testRevertWhitelistMintLimit() public {
        address minter = address(345);
        vm.startPrank(creator);
        collection.addPresalePhase(presalePhaseConfig1);
        vm.stopPrank();
        deal(minter, 350);
        uint256 _startTime = collection.getPresaleConfig()[0].startTime;
        skip(_startTime);
        vm.expectRevert();
        _mintWhitelist(minter, 3, 0, 180);
    }

    function testRevert_TradeWhileNotUnlocked() public {
        address minter = address(345);
        deal(minter, 350);
        _mintPublic(collection, minter, 1, singleMintCost);
        vm.expectRevert();
        collection.safeTransferFrom(minter, address(456), 1);
    }

    // function testTradingAfterUnlocked() public {
    //     address minter1 = address(345);
    //     address minter2 = address(456);
    //     address marketPlace = address(789);
    //     deal(minter1, 350);
    //     deal(minter2, 350);
    //     vm.prank(creator);
    //     collection.unlockTrading();
    //     _mintPublic(collection, minter1, 2, singleMintCost * 2);
    //     _mintPublic(collection, minter2, 2, singleMintCost * 2);
    //     vm.prank(minter1);
    //     collection.approve(marketPlace, 1);
    //     vm.prank(minter2);
    //     collection.approve(marketPlace, 4);
    //     vm.startPrank(marketPlace);
    //     collection.safeTransferFrom(minter1, address(789), 1);
    //     collection.safeTransferFrom(minter2, address(789), 4);
    //     vm.stopPrank();
    // }

    function testEditAndRemovePhase() public {
        vm.startPrank(creator);
        collection.addPresalePhase(presalePhaseConfig1);
        collection.addPresalePhase(presalePhaseConfig1);
        assertEq(collection.getPresaleConfig().length, 2);
        vm.warp(0);
        collection.removePresalePhase(2);
        assertEq(collection.getPresaleConfig().length, 1);
        assertEq(collection.getPresaleConfig()[0].name, "Test Phase");
        vm.stopPrank();
    }

    function testUnrevealedURI() public {
        assertEq(collection.baseURI(), "https://example.com/");
        deal(address(345), 300);
        _mintPublic(collection, address(345), 1, singleMintCost);
        assertEq(collection.tokenURI(1), "https://example.com/");
        vm.prank(creator);
        collection.reveal("https://newURI.com/");
        assertEq(collection.tokenURI(1), "https://newURI.com/1");
    }

    function testRoyaltyInfo() public {
        deal(address(345), 300);
        _mintPublic(collection, address(345), 1, singleMintCost);
        (address receiver, uint256 royaltyValue) = collection.royaltyInfo(1, singleMintCost);
        assertEq(receiver, creator);
        assertEq(royaltyValue, 5);
    }

    function testOwner() public {
        assertEq(collection.owner(), creator);
        vm.prank(creator);
        collection.transferOwnership(address(456));
        assertEq(collection.owner(), address(456));
    }

    function testSupply() public view {
        assertEq(collection.maxSupply(), 100);
        assertEq(collection.totalMinted(), 0);
    }

    function testBurn() public {
        address minter = address(345);
        deal(minter, 300);
        _mintPublic(collection, minter, 1, singleMintCost);
        vm.prank(minter);
        collection.burn(1);
        assertEq(collection.balanceOf(minter), 0);
        assertEq(collection.maxSupply(), 100);
    }

    function testRevertMintWhilePhaseNotLive() public {
        address minter = address(345);
        vm.startPrank(creator);
        collection.addPresalePhase(presalePhaseConfig1);
        collection.addPresalePhase(presalePhaseConfig2);
        vm.stopPrank();
        uint256 _startTime = collection.getPresaleConfig()[0].startTime;
        vm.warp(_startTime);
        deal(minter, 300);
        vm.expectRevert();
        _mintWhitelist(minter, 2, 1, 120);
    }

    function _testNoMintLimit(uint256 amount) internal {
        address minter = address(456);
        deal(minter, 1 ether);
        (
            uint256 previousMinterNftBal,
            uint256 previousCreatorEthBal,
            uint256 previousPlatformEthBal,
            uint256 previousTotalMinted
        ) = _getOldData(minter, collection2);
        _mintPublic(collection2, minter, amount, singleMintCost * amount);
        _verifyOldDataWithNew(
            minter,
            previousMinterNftBal,
            amount,
            previousCreatorEthBal,
            previousPlatformEthBal,
            previousTotalMinted,
            collection2
        );
    }

    function testSupplyAdjustmentAfterSaleEnd() public {
        _testNoMintLimit(60);
        vm.prank(creator);
        collection2.finalizeSale(address(999));
        assertEq(collection2.getMintableSupply(), 60);
        assertEq(collection2.maxSupply(), 66);
        assertEq(collection2.balanceOf(address(999)), 6);
        console.log(address(collection2).balance);
    }
}
