class User < ActiveRecord::Base
  attr_accessible :name, :provider, :uid, :token, :secret

  def create_with_omniauth(auth)
    user = User.new
    user.provider = auth.provider
    user.uid = auth.uid
    user.name = auth.extra.raw_info.screen_name
    user.save!
  end

end
