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

  def get_twitter_client
    twitter = Twitter::Client.new(:oauth_token => current_user.token,
                                  :oauth_token_secret => current_user.secret)
  end

  def process_tweets
    get_details
  end

  def get_details

    @aaronjgs = Array.new

    client = get_twitter_client
    friends = client.friends(params[:twitter_handle])

    count = 0

    friends.each do |friend|

      screen_name = friend.screen_name

      if !friend.protected

        total_tweets = friend.statuses_count
        last_tweet_time = friend.status[:created_at]

        if total_tweets > 200
          page_number = total_tweets / 200
        else
          page_number = 1
        end

        if page_number > 16
          first_tweet_time = "Not Available"
        else
          tweets = client.user_timeline(screen_name, :page => page_number, :count => 200)
          first_tweet_time = tweets.last.created_at
        end

        logger.info "************"
        logger.info page_number
        logger.info total_tweets
        logger.info "************"

        aaronjg = Aaronjg.new(screen_name, total_tweets, first_tweet_time, last_tweet_time, "No")
        @aaronjgs << aaronjg
        count += 1

        if count == 3
          break
        end
      else
        aaronjg = Aaronjg.new(screen_name, "Not Available", "Not Available", "Not Available", "Yes")
        @aaronjgs << aaronjg
      end
    end

    return @aaronjgs

  end
end