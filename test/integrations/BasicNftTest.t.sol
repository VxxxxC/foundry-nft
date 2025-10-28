// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {Vm} from "forge-std/Vm.sol";
import {DeployBasicNft} from "../../script/DeployBasicNft.s.sol";
import {BasicNft} from "../../src/BasicNft.sol";

contract BasicNftTest is Test {
    DeployBasicNft public deployer;
    BasicNft public basicNft;

    address public user = makeAddr("user");
    address public bob = makeAddr("bob");
    address public alice = makeAddr("alice");

    string public constant TOKEN_URI_1 = "ipfs://QmExample1";
    string public constant TOKEN_URI_2 = "ipfs://QmExample2";

    function setUp() public {
        deployer = new DeployBasicNft();
        basicNft = deployer.run();
    }

    // ============ Metadata Tests ============

    function testNameIsCorrect() public view {
        string memory expectedName = "BasicNft";
        string memory actualName = basicNft.name();
        assert(
            keccak256(abi.encodePacked(expectedName)) == 
            keccak256(abi.encodePacked(actualName))
        );
    }

    function testSymbolIsCorrect() public view {
        string memory expectedSymbol = "BNFT";
        string memory actualSymbol = basicNft.symbol();
        assert(
            keccak256(abi.encodePacked(expectedSymbol)) == 
            keccak256(abi.encodePacked(actualSymbol))
        );
    }

    // ============ Minting Tests ============

    function testMintNft() public {
        vm.prank(user);
        basicNft.mintNft(TOKEN_URI_1);

        assertEq(basicNft.balanceOf(user), 1);
        assertEq(basicNft.ownerOf(0), user);
    }

    function testMintMultipleNfts() public {
        vm.startPrank(user);
        basicNft.mintNft(TOKEN_URI_1);
        basicNft.mintNft(TOKEN_URI_2);
        vm.stopPrank();

        assertEq(basicNft.balanceOf(user), 2);
        assertEq(basicNft.ownerOf(0), user);
        assertEq(basicNft.ownerOf(1), user);
    }

    function testMintIncrementsTokenCounter() public {
        vm.prank(user);
        basicNft.mintNft(TOKEN_URI_1);
        assertEq(basicNft.ownerOf(0), user);

        vm.prank(bob);
        basicNft.mintNft(TOKEN_URI_2);
        assertEq(basicNft.ownerOf(1), bob);
    }

    function testMintToContractWithoutReceiver() public {
        address contractWithoutReceiver = address(new ContractWithoutReceiver());
        
        vm.prank(contractWithoutReceiver);
        vm.expectRevert();
        basicNft.mintNft(TOKEN_URI_1);
    }

    function testMintEmitsTransferEvent() public {
        vm.expectEmit(true, true, true, false);
        emit Transfer(address(0), user, 0);

        vm.prank(user);
        basicNft.mintNft(TOKEN_URI_1);
    }

    // ============ TokenURI Tests ============

    function testTokenURI() public {
        vm.prank(user);
        basicNft.mintNft(TOKEN_URI_1);

        string memory uri = basicNft.tokenURI(0);
        assert(
            keccak256(abi.encodePacked(uri)) == 
            keccak256(abi.encodePacked(TOKEN_URI_1))
        );
    }

    function testTokenURIForMultipleTokens() public {
        vm.startPrank(user);
        basicNft.mintNft(TOKEN_URI_1);
        basicNft.mintNft(TOKEN_URI_2);
        vm.stopPrank();

        assert(
            keccak256(abi.encodePacked(basicNft.tokenURI(0))) == 
            keccak256(abi.encodePacked(TOKEN_URI_1))
        );
        assert(
            keccak256(abi.encodePacked(basicNft.tokenURI(1))) == 
            keccak256(abi.encodePacked(TOKEN_URI_2))
        );
    }

    // ============ Balance Tests ============

    function testBalanceOfZeroInitially() public view {
        assertEq(basicNft.balanceOf(user), 0);
    }

    function testBalanceOfAfterMint() public {
        vm.prank(user);
        basicNft.mintNft(TOKEN_URI_1);

        assertEq(basicNft.balanceOf(user), 1);
    }

    function testBalanceOfZeroAddress() public {
        vm.expectRevert();
        basicNft.balanceOf(address(0));
    }

    // ============ Ownership Tests ============

    function testOwnerOfAfterMint() public {
        vm.prank(user);
        basicNft.mintNft(TOKEN_URI_1);

        assertEq(basicNft.ownerOf(0), user);
    }

    function testOwnerOfNonexistentToken() public {
        vm.expectRevert();
        basicNft.ownerOf(999);
    }

    // ============ Transfer Tests ============

    function testTransferFrom() public {
        vm.prank(user);
        basicNft.mintNft(TOKEN_URI_1);

        vm.prank(user);
        basicNft.transferFrom(user, bob, 0);

        assertEq(basicNft.ownerOf(0), bob);
        assertEq(basicNft.balanceOf(user), 0);
        assertEq(basicNft.balanceOf(bob), 1);
    }

    function testTransferFromNotOwner() public {
        vm.prank(user);
        basicNft.mintNft(TOKEN_URI_1);

        vm.prank(bob);
        vm.expectRevert();
        basicNft.transferFrom(user, bob, 0);
    }

    function testTransferToZeroAddress() public {
        vm.prank(user);
        basicNft.mintNft(TOKEN_URI_1);

        vm.prank(user);
        vm.expectRevert();
        basicNft.transferFrom(user, address(0), 0);
    }

    function testSafeTransferFrom() public {
        vm.prank(user);
        basicNft.mintNft(TOKEN_URI_1);

        vm.prank(user);
        basicNft.safeTransferFrom(user, bob, 0);

        assertEq(basicNft.ownerOf(0), bob);
        assertEq(basicNft.balanceOf(bob), 1);
    }

    function testSafeTransferFromWithData() public {
        vm.prank(user);
        basicNft.mintNft(TOKEN_URI_1);

        bytes memory data = "test data";
        vm.prank(user);
        basicNft.safeTransferFrom(user, bob, 0, data);

        assertEq(basicNft.ownerOf(0), bob);
    }

    function testSafeTransferToContractWithoutReceiver() public {
        vm.prank(user);
        basicNft.mintNft(TOKEN_URI_1);

        address contractWithoutReceiver = address(new ContractWithoutReceiver());

        vm.prank(user);
        vm.expectRevert();
        basicNft.safeTransferFrom(user, contractWithoutReceiver, 0);
    }

    function testTransferEmitsEvent() public {
        vm.prank(user);
        basicNft.mintNft(TOKEN_URI_1);

        vm.expectEmit(true, true, true, false);
        emit Transfer(user, bob, 0);

        vm.prank(user);
        basicNft.transferFrom(user, bob, 0);
    }

    // ============ Approval Tests ============

    function testApprove() public {
        vm.prank(user);
        basicNft.mintNft(TOKEN_URI_1);

        vm.prank(user);
        basicNft.approve(bob, 0);

        assertEq(basicNft.getApproved(0), bob);
    }

    function testApproveEmitsEvent() public {
        vm.prank(user);
        basicNft.mintNft(TOKEN_URI_1);

        vm.expectEmit(true, true, true, false);
        emit Approval(user, bob, 0);

        vm.prank(user);
        basicNft.approve(bob, 0);
    }

    function testApproveNotOwner() public {
        vm.prank(user);
        basicNft.mintNft(TOKEN_URI_1);

        vm.prank(bob);
        vm.expectRevert();
        basicNft.approve(alice, 0);
    }

    function testTransferFromWithApproval() public {
        vm.prank(user);
        basicNft.mintNft(TOKEN_URI_1);

        vm.prank(user);
        basicNft.approve(bob, 0);

        vm.prank(bob);
        basicNft.transferFrom(user, alice, 0);

        assertEq(basicNft.ownerOf(0), alice);
    }

    function testApprovalClearedAfterTransfer() public {
        vm.prank(user);
        basicNft.mintNft(TOKEN_URI_1);

        vm.prank(user);
        basicNft.approve(bob, 0);

        vm.prank(user);
        basicNft.transferFrom(user, alice, 0);

        assertEq(basicNft.getApproved(0), address(0));
    }

    function testGetApprovedNonexistentToken() public {
        vm.expectRevert();
        basicNft.getApproved(999);
    }

    // ============ SetApprovalForAll Tests ============

    function testSetApprovalForAll() public {
        vm.prank(user);
        basicNft.setApprovalForAll(bob, true);

        assertTrue(basicNft.isApprovedForAll(user, bob));
    }

    function testSetApprovalForAllEmitsEvent() public {
        vm.expectEmit(true, true, false, true);
        emit ApprovalForAll(user, bob, true);

        vm.prank(user);
        basicNft.setApprovalForAll(bob, true);
    }

    function testSetApprovalForAllFalse() public {
        vm.startPrank(user);
        basicNft.setApprovalForAll(bob, true);
        basicNft.setApprovalForAll(bob, false);
        vm.stopPrank();

        assertFalse(basicNft.isApprovedForAll(user, bob));
    }

    function testTransferFromWithApprovalForAll() public {
        vm.prank(user);
        basicNft.mintNft(TOKEN_URI_1);

        vm.prank(user);
        basicNft.setApprovalForAll(bob, true);

        vm.prank(bob);
        basicNft.transferFrom(user, alice, 0);

        assertEq(basicNft.ownerOf(0), alice);
    }

    function testApprovalForAllMultipleTokens() public {
        vm.startPrank(user);
        basicNft.mintNft(TOKEN_URI_1);
        basicNft.mintNft(TOKEN_URI_2);
        basicNft.setApprovalForAll(bob, true);
        vm.stopPrank();

        vm.startPrank(bob);
        basicNft.transferFrom(user, bob, 0);
        basicNft.transferFrom(user, bob, 1);
        vm.stopPrank();

        assertEq(basicNft.ownerOf(0), bob);
        assertEq(basicNft.ownerOf(1), bob);
        assertEq(basicNft.balanceOf(bob), 2);
    }

    // ============ SupportsInterface Tests ============

    function testSupportsInterface() public view {
        // ERC721 interface ID
        assertTrue(basicNft.supportsInterface(0x80ac58cd));
        // ERC165 interface ID
        assertTrue(basicNft.supportsInterface(0x01ffc9a7));
        // Random interface ID should return false
        assertFalse(basicNft.supportsInterface(0x12345678));
    }

    // ============ Complex Scenario Tests ============

    function testMintTransferAndMintAgain() public {
        // User mints first NFT
        vm.prank(user);
        basicNft.mintNft(TOKEN_URI_1);
        assertEq(basicNft.ownerOf(0), user);

        // User transfers to Bob
        vm.prank(user);
        basicNft.transferFrom(user, bob, 0);
        assertEq(basicNft.ownerOf(0), bob);

        // Alice mints second NFT
        vm.prank(alice);
        basicNft.mintNft(TOKEN_URI_2);
        assertEq(basicNft.ownerOf(1), alice);

        // Check balances
        assertEq(basicNft.balanceOf(user), 0);
        assertEq(basicNft.balanceOf(bob), 1);
        assertEq(basicNft.balanceOf(alice), 1);
    }

    function testApprovalChain() public {
        // User mints and approves Bob
        vm.startPrank(user);
        basicNft.mintNft(TOKEN_URI_1);
        basicNft.approve(bob, 0);
        vm.stopPrank();

        // Bob transfers to Alice using approval
        vm.prank(bob);
        basicNft.transferFrom(user, alice, 0);

        // Alice approves Bob again
        vm.prank(alice);
        basicNft.approve(bob, 0);

        // Bob transfers to himself
        vm.prank(bob);
        basicNft.transferFrom(alice, bob, 0);

        assertEq(basicNft.ownerOf(0), bob);
    }

    // Events
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
}

// Helper contract for testing safe transfer failures
contract ContractWithoutReceiver {
    // This contract doesn't implement ERC721Receiver
}