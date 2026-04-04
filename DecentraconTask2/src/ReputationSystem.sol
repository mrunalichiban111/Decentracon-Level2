// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract ReputationSystem {
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

    // Track interactions
    mapping(address => mapping(address => bool)) public hasInteracted;

    // Prevent duplicate reviews
    mapping(address => mapping(address => bool)) public hasReviewed;

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

    // ---------------- INTERACTION ----------------
    function recordInteraction(address user1, address user2) external {
        require(user1 != user2, "Cannot interact with self");
        require(user1 != address(0) && user2 != address(0), "Invalid address");

        hasInteracted[user1][user2] = true;
        hasInteracted[user2][user1] = true;

        emit InteractionRecorded(user1, user2);
    }

    // ---------------- REVIEW ----------------
    function submitReview(
        address _to,
        uint8 _rating,
        string memory _comment
    ) public {
        require(msg.sender != _to, "Cannot review yourself");
        require(_to != address(0), "Invalid address");
        require(_rating >= 1 && _rating <= 5, "Rating must be 1-5");

        require(hasInteracted[msg.sender][_to], "No interaction found");
        require(!hasReviewed[msg.sender][_to], "Already reviewed");

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

        hasReviewed[msg.sender][_to] = true;

        emit ReviewSubmitted(msg.sender, _to, _rating, _comment);
    }

    // ---------------- AVERAGE ----------------
    function getAverageRating(address _user) public view returns (uint256) {
        if (users[_user].reviewCount == 0) {
            return 0;
        }
        return users[_user].totalRating / users[_user].reviewCount;
    }

    // ---------------- DELETE ----------------
    function deleteReview(address _user, uint256 index) public {
        require(index < reviews[_user].length, "Invalid index");

        Review memory reviewToDelete = reviews[_user][index];

        require(reviewToDelete.reviewer == msg.sender, "Not your review");

        // Update reputation BEFORE deletion
        users[_user].totalRating -= reviewToDelete.rating;
        users[_user].reviewCount--;

        // Allow reviewer to review again if deleted
        hasReviewed[msg.sender][_user] = false;

        // Gas-efficient delete (swap & pop)
        uint256 lastIndex = reviews[_user].length - 1;

        if (index != lastIndex) {
            reviews[_user][index] = reviews[_user][lastIndex];
        }

        reviews[_user].pop();

        emit ReviewDeleted(msg.sender, _user, index);
    }

    // ---------------- VIEW HELPERS ----------------
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