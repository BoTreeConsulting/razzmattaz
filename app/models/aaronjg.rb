class Aaronjg

  attr_accessor :screen_name, :tweet_count, :first_tweet_date , :last_tweet_date, :tweets_protected

  def initialize(screen_name, tweet_count, first_tweet_date, last_tweet_date, tweets_protected)
    @screen_name = screen_name
    @tweet_count = tweet_count
    @first_tweet_date = first_tweet_date
    @last_tweet_date = last_tweet_date
    @tweets_protected = tweets_protected
  end

end