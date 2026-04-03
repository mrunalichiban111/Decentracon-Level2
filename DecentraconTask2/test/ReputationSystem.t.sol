// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/ReputationSystem.sol";

contract ReputationSystemTest is Test {
    ReputationSystem contractInstance;

    address user1 = address(0x1);
    address user2 = address(0x2);
    address user3 = address(0x3);

    function setUp() public {
        contractInstance = new ReputationSystem();
    }

    // =========================================================
    // 1. INPUT VALIDATION AND BASIC CONSTRAINTS
    // =========================================================

    function testCannotSelfReview() public {
        vm.prank(user1);
        vm.expectRevert();
        contractInstance.submitReview(user1, 5, "self");
    }

    function testInvalidRatingFails() public {
        vm.prank(user1);
        vm.expectRevert();
        contractInstance.submitReview(user2, 0, "bad");

        vm.prank(user1);
        vm.expectRevert();
        contractInstance.submitReview(user2, 6, "bad");
    }

    function testZeroDivisionHandled() public {
        uint avg = contractInstance.getAverageRating(user1);
        assertEq(avg, 0);
    }

    // =========================================================
    // 2. DUPLICATE AND SPAM PREVENTION
    // =========================================================

    function testDuplicateReviewFails() public {
        contractInstance.recordInteraction(user1, user2);

        vm.prank(user1);
        contractInstance.submitReview(user2, 5, "first");

        vm.prank(user1);
        vm.expectRevert();
        contractInstance.submitReview(user2, 4, "second");
    }

    function testNoBulkSpam() public {
        contractInstance.recordInteraction(user1, user2);

        vm.startPrank(user1);

        contractInstance.submitReview(user2, 5, "1");

        vm.expectRevert();
        contractInstance.submitReview(user2, 5, "2");

        vm.stopPrank();
    }

    // =========================================================
    // 3. ACCESS CONTROL AND DATA INTEGRITY
    // =========================================================

    function testOnlyReviewerCanDelete() public {
        contractInstance.recordInteraction(user1, user2);

        vm.prank(user1);
        contractInstance.submitReview(user2, 5, "test");

        vm.prank(user3);
        vm.expectRevert();
        contractInstance.deleteReview(user2, 0);
    }

    function testDeleteMaintainsIntegrity() public {
        contractInstance.recordInteraction(user1, user2);

        vm.prank(user1);
        contractInstance.submitReview(user2, 5, "test");

        vm.prank(user1);
        contractInstance.deleteReview(user2, 0);

        (uint total, uint count) = contractInstance.users(user2);

        assertEq(total, 0);
        assertEq(count, 0);
    }
    function testDeletePreservesCorrectData() public {
        contractInstance.recordInteraction(user1, user2);
        contractInstance.recordInteraction(user3, user2);

        vm.prank(user1);
        contractInstance.submitReview(user2, 5, "A");

        vm.prank(user3);
        contractInstance.submitReview(user2, 3, "B");

        vm.prank(user1);
        contractInstance.deleteReview(user2, 0);

        ReputationSystem.Review memory r = contractInstance.getReview(user2, 0);

        assertEq(r.reviewer, user3);
        assertEq(r.rating, 3);
    }
    function testAverageAfterDelete() public {
        contractInstance.recordInteraction(user1, user2);

        vm.prank(user1);
        contractInstance.submitReview(user2, 5, "test");

        vm.prank(user1);
        contractInstance.deleteReview(user2, 0);

        uint avg = contractInstance.getAverageRating(user2);
        assertEq(avg, 0);
    }
    

    // =========================================================
    // 4. REPUTATION CALCULATION IMPROVEMENTS
    // =========================================================

    function testAverageRatingCorrect() public {
        contractInstance.recordInteraction(user1, user2);
        contractInstance.recordInteraction(user3, user2);

        vm.prank(user1);
        contractInstance.submitReview(user2, 4, "good");

        vm.prank(user3);
        contractInstance.submitReview(user2, 2, "ok");

        uint avg = contractInstance.getAverageRating(user2);
        assertEq(avg, 3);
    }

    // =========================================================
    // 5. EVENT LOGGING AND TRANSPARENCY
    // =========================================================

    function testReviewSubmittedEvent() public {
        contractInstance.recordInteraction(user1, user2);

        vm.prank(user1);
        vm.expectEmit(true, true, false, true);
        emit ReputationSystem.ReviewSubmitted(user1, user2, 5, "test");

        contractInstance.submitReview(user2, 5, "test");
    }

    function testReviewDeletedEvent() public {
        contractInstance.recordInteraction(user1, user2);

        vm.prank(user1);
        contractInstance.submitReview(user2, 5, "test");

        vm.prank(user1);
        vm.expectEmit(true, true, false, true);
        emit ReputationSystem.ReviewDeleted(user1, user2, 0);

        contractInstance.deleteReview(user2, 0);
    }

    // =========================================================
    // 6. INTERACTION VERIFICATION MECHANISM
    // =========================================================

    function testInteractionRequired() public {
        vm.prank(user1);
        vm.expectRevert();
        contractInstance.submitReview(user2, 5, "no interaction");
    }

    function testInteractionAllowsReview() public {
        contractInstance.recordInteraction(user1, user2);

        vm.prank(user1);
        contractInstance.submitReview(user2, 5, "valid");

        (uint total, uint count) = contractInstance.users(user2);
        assertEq(total, 5);
        assertEq(count, 1);
    }

    // =========================================================
    // 7. SECURITY ENHANCEMENTS (BASIC ABUSE CHECKS)
    // =========================================================

    function testDifferentUsersCanReviewSameTarget() public {
        contractInstance.recordInteraction(user1, user2);
        contractInstance.recordInteraction(user3, user2);

        vm.prank(user1);
        contractInstance.submitReview(user2, 5, "good");

        vm.prank(user3);
        contractInstance.submitReview(user2, 3, "ok");

        (uint total, uint count) = contractInstance.users(user2);

        assertEq(total, 8);
        assertEq(count, 2);
    }

    // =========================================================
    // 8. STORAGE AND GAS OPTIMIZATION (BEHAVIOR CHECK)
    // =========================================================

    function testDeleteMiddleElement() public {
        contractInstance.recordInteraction(user1, user2);
        contractInstance.recordInteraction(user3, user2);

        vm.prank(user1);
        contractInstance.submitReview(user2, 5, "A");

        vm.prank(user3);
        contractInstance.submitReview(user2, 3, "B");

        vm.prank(user1);
        contractInstance.deleteReview(user2, 0);

        uint len = contractInstance.getReviewCount(user2);
        assertEq(len, 1);
    }
}
