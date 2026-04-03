// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract ReputationSystem {
    // Intentionally incomplete starter contract.
    // Participants are expected to fix logic, add validations,
    // implement interaction tracking, and secure deletion.

    struct Review {
        address reviewer;
        uint8 rating; // 1-5
        string comment;
        uint256 timestamp;
    }

    struct User {
        uint256 totalRating;
        uint256 reviewCount;
    }

    mapping(address => User) public users;
    mapping(address => Review[]) public reviews;

    // Placeholder storage for interaction tracking.
    mapping(address => mapping(address => bool)) public hasInteracted;

    // Provided for testing and transparency.
    event ReviewSubmitted(
        address indexed reviewer,
        address indexed reviewee,
        uint8 rating,
        string comment
    );

    event ReviewDeleted(
        address indexed reviewer,
        address indexed reviewee,
        uint256 index
    );

    event InteractionRecorded(address indexed user1, address indexed user2);

    // Students are expected to implement proper interaction logic.
    function recordInteraction(address user1, address user2) external {
        user1;
        user2;
        // TODO: mark valid interaction in storage
    }

    // - no self-review check
    // - no rating bounds check
    // - no duplicate check
    // - no interaction validation
    function submitReview(
        address _to,
        uint8 _rating,
        string memory _comment
    ) public {
        reviews[_to].push(
            Review({
                reviewer: msg.sender,
                rating: _rating,
                comment: _comment,
                timestamp: block.timestamp
            })
        );

        users[_to].totalRating += _rating;
        users[_to].reviewCount++;

        emit ReviewSubmitted(msg.sender, _to, _rating, _comment);
    }

    // No zero-review guard.
    function getAverageRating(address _user) public view returns (uint256) {
        return users[_user].totalRating / users[_user].reviewCount;
    }

    // No interaction tracking.
    // - anyone can delete
    // - does not update totalRating / reviewCount
    // - uses delete instead of safe removal
    function deleteReview(address _user, uint256 index) public {
        delete reviews[_user][index];
        emit ReviewDeleted(msg.sender, _user, index);
    }
    function bulkReview(address _to, uint8 _rating) public {
        for (uint i = 0; i < 5; i++) {
            reviews[_to].push(
                Review(msg.sender, _rating, "spam", block.timestamp)
            );
        }
    }

    // Helper functions provided so tests can inspect state.
    function getReviewCount(address _user) public view returns (uint256) {
        return reviews[_user].length;
    }

    function getReview(
        address _user,
        uint256 index
    ) public view returns (Review memory) {
        require(index < reviews[_user].length, "Invalid index");
        return reviews[_user][index];
    }
}
