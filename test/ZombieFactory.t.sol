// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {ZombieFactory} from "../src/ZombieFactory.sol";

contract ZombieFactoryTest is Test {
    ZombieFactory factory;
    address user1 = address(0x1111);
    address user2 = address(0x2222);

    function setUp() public {
        factory = new ZombieFactory();
    }

    function test_User1CreatesFirstZombie() public {
        vm.prank(user1);
        uint256 id = factory.createZombie("User1Zombie");
        
        assertEq(id, 0);
        assertEq(factory.totalZombies(), 1);
        assertEq(factory.ownerZombieCount(user1), 1);
        assertEq(factory.zombieToOwner(id), user1);

        (string memory name, , uint256 createdAt) = factory.getZombie(id);
        assertEq(name, "User1Zombie");
        assertEq(createdAt, block.timestamp);
    }

    function test_TwoUsersGetDifferentIds() public {
        vm.prank(user1);
        uint256 id1 = factory.createZombie("User1");
        
        vm.prank(user2);
        uint256 id2 = factory.createZombie("User2");

        assertEq(id1, 0);
        assertEq(id2, 1);
        assertEq(factory.totalZombies(), 2);
    }

    function test_CannotCreateWithEmptyName() public {
        vm.prank(user1);
        vm.expectRevert("Empty name");
        factory.createZombie("");
    }

    function test_CannotCreateSecondZombie() public {
        vm.prank(user1);
        factory.createZombie("First");
        
        vm.prank(user1);
        vm.expectRevert("Already has zombie");
        factory.createZombie("Second");
    }

    function test_DnaIsInCorrectRange() public {
        vm.prank(user1);
        uint256 id = factory.createZombie("User1");
        
        (, uint256 dna, ) = factory.getZombie(id);
        assertLt(dna, factory.DNA_MODULUS());
    }
}