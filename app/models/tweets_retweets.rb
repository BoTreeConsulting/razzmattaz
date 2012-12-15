class TweetsRetweets

  attr_accessor :tweet_id, :text, :retweet_ids

  def initialize(tweet_id, text, retweet_ids)
    @tweet_id = tweet_id
    @text = text
    @retweet_ids = retweet_ids
  end


end