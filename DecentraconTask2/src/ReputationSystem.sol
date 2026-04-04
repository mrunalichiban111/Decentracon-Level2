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

    
    mapping(address => mapping(address => bool)) public hasInteracted;

    
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

    
    function recordInteraction(address user1, address user2) external {
        user1;
        user2;
        
    }

    
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

    
    function getAverageRating(address _user) public view returns (uint256) {
        return users[_user].totalRating / users[_user].reviewCount;
    }

    
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
