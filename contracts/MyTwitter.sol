//SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";

pragma solidity ^0.8.17;

//blueprint for userprofile
interface IProfile {
    struct Userprofile {
        string displayName;
        string bio;
    }

    function getProfile(
        address _user
    ) external view returns (UserProfile memory);
}

contract MyTwitter is Ownable {
    //tweet length as a state variable
    uint16 public MAX_TWEET_LENGTH = 280;

    //define a tweet struct
    struct Tweet {
        uint256 id;
        address author;
        string content;
        uint256 timestamp;
        uint256 likes;
    }

    //match each user to a particular tweet
    mapping(address => Tweet[]) public tweets;

    //define profile contract
    IProfile profileContract;

    //create event for creating the tweet
    event TweetCreated(
        uint256 id,
        address author,
        string content,
        uint256 timestamp
    );

    //create event for liking the tweet
    event TweetLiked(
        address liker,
        address tweetAuthor,
        uint256 tweetId,
        uint256 newLikeCount
    );

    //create event for unliking the tweet
    event TweetUnliked(
        address unliker,
        address tweetAuthor,
        uint256 tweetId,
        uint256 newLikeCount
    );

    modifier onlyRegistered() {
        IProfile.UserProfile memory userProfileTemp = profileContract
            .getProfile(msg.sender);
        require(
            bytes(userProfileTemp.displayName).length > 0,
            "USER NOT REGISTERED"
        );
        _;
    }

    constructor(address _profileContract) {
        //Initialize connection to the user profile
        profileContract = IProfile(_profileContract);
    }

    //enable only owner to change tweet length
    function changeTweetlength(uint16 newTweetLength) public onlyOwner {
        MAX_TWEET_LENGTH = newTweetLength;
    }

    //fxn to get total likes for a particular tweet
    function getTotalLikes(address _author) external view returns (uint) {
        uint totalLikes;

        for (uint i = 0; i < tweets[_author].length; i++) {
            totalLikes += tweets[_author][i].likes;
        }

        return totalLikes;
    }

    //writes a tweet and maps it to a particulaar user
    function createTweet(string memory _tweet) public onlyRegistered {
        //limit length the of the tweet
        require(bytes(_tweet).length <= MAX_TWEET_LENGTH, "Tweet is too long!");

        //create an instance of the struct
        Tweet memory newTweet = Tweet({
            id: tweets[msg.sender].length, //give tweet unique ID
            author: msg.sender,
            content: _tweet,
            timestamp: block.timestamp,
            likes: 0
        });
        tweets[msg.sender].push(newTweet); //tweet

        emit TweetCreated(
            newTweet.id,
            newTweet.author,
            newTweet.content,
            newTweet.timestamp
        ); //calls event after tweet is created
    }

    //fxn to like tweet
    function likeTweet(address author, uint256 id) external onlyRegistered {
        require(tweets[author][id].id == id, "TWEET DOES NOT EXIST"); //require for the tweet to exist to prevent attempts to break out of the contract with an invalid id or author
        tweets[author][id].likes++;

        //event called for the tweet is liked
        emit TweetLiked(msg.sender, author, id, tweets[author][id].likes);
    }

    //fxn to unlike tweet, tweets cannot be less than 0
    function unlikeTweet(address author, uint256 id) external onlyRegistered {
        require(tweets[author][id].id == id, "TWEET DOES NOT EXIST");
        require(tweets[author][id].likes > 0, "TWEET HAS NO LIKES");

        tweets[author][id].likes--;

        //event called when tweet is unliked
        emit TweetUnliked(msg.sender, author, id, tweets[author][id].likes);
    }

    //returns a particular tweet from the owner
    function getTweet(uint _i) public view returns (Tweet memory) {
        return tweets[msg.sender][_i];
    }

    //returns all previous tweets from owner
    function getAllTweets(address _owner) public view returns (Tweet[] memory) {
        return tweets[_owner];
    }
}
