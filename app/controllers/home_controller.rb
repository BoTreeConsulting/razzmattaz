class HomeController < ApplicationController

  def create
    auth = request.env["omniauth.auth"]
    user = User.find_by_provider_and_uid(auth.provider, auth.uid)
    if user.present?
      user.token = auth.credentials.token
      user.secret = auth.credentials.secret
      user.save!
    else
      user = User.new
      user.provider = auth.provider
      user.uid = auth.uid
      user.name = auth.extra.raw_info.screen_name
      user.token = auth.credentials.token
      user.secret = auth.credentials.secret
      user.save!
    end
    session[:user_id] = user.id
    redirect_to '/home/search'
  end

  def process_tweets

    retweets = Array.new
    retweet_ids = Array.new
    @tweets_retweets_arr = Array.new

    twitter = Twitter::Client.new(:oauth_token => current_user.token,
                                  :oauth_token_secret => current_user.secret)

    tweets = twitter.user_timeline(params[:twitter_handle], :page => 1, :count => 5)

    tweets.each do |tweet|
      retweet_ids = []
      retweets = []

      begin
        retweets = twitter.retweets(tweet.id)
      rescue Exception => e
        puts "Error while fetching Retweets - #{e.message}"
      end

      retweets.each do |retweet|
        retweet_ids << retweet.id
      end

      tweets_retweets = TweetsRetweets.new(tweet.id, tweet.text, retweet_ids)
      @tweets_retweets_arr << tweets_retweets

    end

    return @tweets_retweets_arr

  end

end