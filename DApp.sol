pragma solidity ^0.8.4;

contract fakeNewsDetector {

    //Structure for a News Item
    struct News_Item {
        uint Id;    //Unique ID of the news item
        string title;  //Title of the news item
        string content; //Content of the news item
        string author;  //Author of the news item
        string topic; // Politics, Sports, Health, etc.
        string hash_of_content; //Hash of the content of the news item
        bool isRated;  //Boolean to check if the news item has been rated already
    }
    //Structure for a Voter
    struct Voter {
        uint Id;
        mapping(string => uint) Trust;   //Trust values of the voter on different topics
    }

    event VoterExists(uint uid);     //Event to be emitted when a voter already exists
    event VoterNotExists(uint uid);  //Event to be emitted when a voter does not exist
    event RatingExists(uint news_id);  //Event to be emitted when a rating already exists
    event RatingNotExists(uint news_id);  //Event to be emitted when a rating does not exist
    event VotingCompleted(uint news_id);  //Event to be emitted when voting is completed
    event NewsItemAdded(string hash_of_content); //Event to be emitted when a news item is added
    event NewsItemNotAdded(string hash_of_content);  //Event to be emitted when a news item is not added

    mapping(uint => Voter) public voters;   //Mapping of voter ID to Voter
    mapping(uint => News_Item) public news_items;   //Mapping of news ID to News Item
    mapping(News_Item => uint) public news_ratings;  //Mapping of News Item to its rating
    mapping(uint => bool) public news_id_exists;   //Mapping of news ID to its existence
    mapping(string => bool) public news_hash_exists;   //Mapping of hash of content to its existence

    // Function to check if the user is registered and register a user otherwise
    function Register_User(uint uid) public returns (bool) {
        for (uint i = 0; i < voters.length; i++) {
            if (voters[i].Id == uid) {
                emit VoterExists(uid);
                revert("You are already registered");
            }
        }
        // If the user is not registered, register the user by creating a new voter object
        emit VoterNotExists(uid);
        // These dummy 1500 ratings are overwritten by the Bootstrap function
        Voter memory voter = Voter(uid, [1500] * 10);
        voters[uid] = voter;
        // Give initial ratings to the users at the time of Registration using the Bootstrap function
        Bootstrap_Voter(voter);
        return true;
    }

    // Function to bootstrap initial ratings according to the examination results
    function Bootstrap_Voter(Voter voter) private {
        uint[] exam_results;
        for (uint i = 0; i < voter.Trust.length; i++) {
        /*
        Take an examination of the user's trust values of every topic by asking them to rate three articles of each.  
        These articles are chosen randomly from a constantly-updating database of admin-rated articles(intitially) and further from user-rated articles. 
        An Initial rating is assigned based on their performance in the examination. 
        We start at 1500 and update based on the examination results.
        */
            Voter.Trust[i] = exam_results[i];
        }
    }

    // Function to add a news item to the app database
    function Add_News_Item(string nTitle, string nContent, string nAuthor, string nTopic) public {
        // Check if the user is registered before he is able to add a news item
        if (checkUserRegistered(msg.sender) == false)
            revert ("User not registered, can't add news item");

        // Check if the news item already exists by matching the hash of content with existing news items
        if (news_hash_exists[nContent.hash()] == true) {
            emit NewsItemNotAdded(nContent.hash());
            revert("News item already exists");
        }
        
        // If the news item does not exist, add it to the database, and update the mappings
        News_Item memory new_news = News_Item(
            news_id = uuid(),
            nTitle,
            nContent,
            nAuthor,
            nTopic,
            content.hash(),
            false
        );
        // Update the mappings indicating the existence of the news item
        news_items[news_id] = new_news;
        news_id_exists[news_id] = true;
        news_hash_exists[new_news.hash_of_content] = true;
        emit NewsItemAdded(new_news.hash_of_content);

        // Perform the voting process for this newly added news item
        Do_Voting(news_items[news_id]);
    }

    // Function to query the rating of a news item
    function Query_Rating(uint news_id) public returns (uint) {
        //If Rating not found for the news item, add the news item and then simulate the voting process and get a rating
        if (news_exists[news_id] == false) {
            emit RatingNotExists(news_id);
            Add_News_Item(news_id);
        }
        //If Rating exists then just return it
        emit RatingExists(news_id);
        return news_ratings[news_items[news_id]];
    }

    // Function to perform the voting process for a news item
    function Do_Voting(News_Item news) public {
        // Every User Rates between [0,10] for the given article
        string cur_topic = news.topic;
        uint64 weighted_sum=0;
        uint64 sum_of_weights=0;

        for (uint i = 0; i < voters.length; i++) {
            uint opinion = ("rating given by user b/w 0-10");
                weighted_sum += voters[i].Trust[topic] * opinion;
                sum_of_weights += voters[i].Trust[topic];
            }
        }
        news.isRated = true;
        // Calculating final public rating
        news_ratings[news] = weighted_sum / sum_of_weights;
        emit VotingCompleted(news_id);
        // Call a function to update the trust values of the user based on the rating of the commitee
        Evaluate_Elo(news);
    }

    function Evaluate_Elo() private {      //Private function
        /* 
        ELECTING THE COMMITTEE
        // Nominate top 10% of all voters as potential committee candidiates
        // Allow the candidates to volunteer for voting in the next 24 hours
        // Select the top 10% of the volunteering candidates, based on their trust values on that topic 
        // If not enough voters volunteer, select the top 10% of the voters based on their trust values on that topic 
        */
        
        for member in committee:
            /*
            VOTING BY THE COMMITTEE
            // Committee members vote on the article to generate a weighted-average rating that is to be used to evaluate other voters' opinions and update their rating
            // Elo Ratings of the committee members themselves are not increased in this process - to make them act selflessly, this will also ensure that the same voter does not become a committee member everytime
            // Committee Members are penalised for if they take wrong decisions
            */
        
        for voter in voters:
            /*
            UPDATING THE TRUST VALUES
            // Elo rating formula used for updating ratings. weight_of_opinion = 1/(1+10^((1500 - rating_of_voter)/400))
            // The weight of opinion is used to update the trust values of the voters: current_rating +/- 30*(score-weight),
            // where score = 1-(abs(rating_of_voter - rating_of_committee)/10)
            */
    }