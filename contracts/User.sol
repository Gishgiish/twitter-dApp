// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

contract Profile {
    struct UserProfile {
        string displayName;
        string bio;
    }

    mapping(address => UserProfile) public profiles;

    function setProfile(string memory _displayName, string memory _bio) public {
        //save UserProfile to the mapping
        profiles[msg.sender] = UserProfile(_displayName, _bio);
    }

    function getProfile(
        address _user
    ) public view returns (UserProfile memory) {
        return profiles[_user];
    }
}
