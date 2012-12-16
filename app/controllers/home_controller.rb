class HomeController < ApplicationController

  require 'uri'

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

    @tweets_retweets_arr = Array.new

    twitter = Twitter::Client.new(:oauth_token => current_user.token,
                                  :oauth_token_secret => current_user.secret)

    tweets = twitter.user_timeline(params[:twitter_handle], :page => 1, :count => 5)

    tweets.each do |tweet|
      tweet_embedded_urls = URI.extract(tweet.text)
      retweet_ids = get_retweet_ids(twitter, tweet.id)
      tweets_retweets = TweetsRetweets.new(tweet.id, tweet.text, tweet_embedded_urls, retweet_ids)
      @tweets_retweets_arr << tweets_retweets
    end

    return @tweets_retweets_arr

  end

  def get_retweet_ids(twitter_client, id)
    retweet_ids = Array.new
    retweets = Array.new
    begin
      retweets = twitter_client.retweets(id)
      retweets.each do |retweet|
        retweet_ids << retweet.id
      end
    rescue Exception => e
      puts "Error while fetching Retweets - #{e.message}"
    end
    retweet_ids
  end

end