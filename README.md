# Decentralized Reputation System — Decentracon Challenge two

## Overview

In today’s digital ecosystem, trust and credibility are often controlled by centralized platforms, making them vulnerable to manipulation, fake reviews, and biased moderation. Users lack ownership over their reputation data, and there is no transparent or tamper-proof way to verify the authenticity of reviews.

This challenge focuses on building a **decentralized, on-chain reputation system** where users can review others in a secure and trust-minimized environment.

You are provided with a **starter smart contract** that contains multiple logical flaws, missing validations, and incomplete features. Your task is to analyze, fix, and extend the contract to make it secure, correct, and production-ready.

---

## Objective

Design and implement a robust reputation system that:

* Allows users to submit reviews and ratings for other users
* Maintains an accurate aggregate reputation score
* Prevents abuse such as spam, fake reviews, and unauthorized actions
* Ensures proper validation and access control
* Passes all provided test cases

---

## Getting Started

### 1. Fork the Repository

Click the **Fork** button and clone your fork:

```
git clone <your-fork-url>
cd <repo-name>
```

---

### 2. Install Foundry (if not installed)

```
curl -L https://foundry.paradigm.xyz | bash
foundryup
```

---

### 3. Run Tests

```
forge test
```

Initially, many tests will fail. Your goal is to modify the contract so that all tests pass.

---

## Rules

* Modify only the contract inside `src/ReputationSystem.sol`
* Do not modify test files
* Do not change function names or signatures
* You may add new state variables or internal logic if required
* Your solution must compile and pass the test suite

---

## Tasks and Requirements

### 1. Input Validation and Constraints

* Prevent users from reviewing themselves
* Ensure ratings are within a valid range (1 to 5)
* Handle edge cases such as division by zero

---

### 2. Duplicate and Spam Prevention

* Prevent the same user from reviewing another user multiple times
* Ensure spam mechanisms (e.g., repeated submissions) are not possible

---

### 3. Access Control and Data Integrity

* Ensure only the reviewer can delete their review
* Maintain consistency of stored data after deletion
* Prevent unauthorized modifications

---

### 4. Reputation Calculation

* Correctly compute average ratings
* Ensure values remain accurate after adding or deleting reviews

---

### 5. Event Logging

* Ensure appropriate events are emitted for:

  * Review submission
  * Review deletion

---

### 6. Interaction Verification

* Users should only be able to review others they have interacted with
* Implement logic using the provided `recordInteraction` function

---

### 7. Storage and Gas Optimization

* Handle review deletion efficiently
* Avoid unnecessary storage operations
* Ensure scalability of the solution

---

## Provided Components

The starter contract already includes:

* Struct definitions (`Review`, `User`)
* Storage mappings
* Event declarations
* Helper view functions:

  * `getReviewCount`
  * `getReview`

These helper functions should **not be modified**.

---

## Evaluation Criteria

Submissions will be evaluated based on:

* Correctness of implementation
* Ability to pass test cases
* Security and robustness
* Proper handling of edge cases
* Code quality and readability

---

## Scoring

* All tests passing → Full score
* Partial tests passing → Partial score
* Compilation failure → Disqualified

---

## Expected Outcome

By the end of this challenge, your contract should:

* Enforce all validations correctly
* Prevent misuse and spam
* Maintain accurate reputation data
* Pass all automated tests

---

## Notes

* The initial contract is intentionally flawed
* Focus on correctness, not just passing tests
* Multiple correct implementations are possible

---

## Submission

Submit your forked repository with your final implementation.

---

## Good Luck

This challenge is designed to test your understanding of smart contract design, security, and real-world problem solving. Approach it methodically and focus on building a correct and robust system.
