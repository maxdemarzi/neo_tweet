# -*- encoding: utf-8 -*-
require "bundler"
Bundler.setup(:default)
Bundler.require

$LOAD_PATH.unshift(Dir.getwd)

configure do
  enable :sessions
  set :key, ENV['CONSUMER_KEY']
  set :secret, ENV['CONSUMER_SECRET']
  set :neo, Neography::Rest.new
end

require "models/user"

use OmniAuth::Builder do
  provider :twitter, settings.key, settings.secret
end

Twitter.configure do |config|
  config.consumer_key    = settings.key
  config.consumer_secret = settings.secret
end

helpers do
  def current_user
    @current_user ||= User.find_by_uid(session[:uid]) if session[:uid]
  end

  def partial(name, options={})
    haml("_#{name.to_s}".to_sym, options.merge(:layout => false))
  end
end

get "/" do
  haml :index
end

get "/auth/twitter/callback" do
  auth = request.env["omniauth.auth"]
  user = User.find_by_uid(auth["uid"]) || User.create_with_omniauth(auth)
  session[:uid] = auth["uid"]
  redirect "/home"
end

get "/auth/failure" do
  redirect "/fail"
end

get "/home" do
  haml :home
end

get "/fail" do
  haml :fail
end

get "/me" do
  @info = current_user.client.user(current_user.nickname)
  haml :me
end

get "/timeline" do
  @tweets = current_user.client.home_timeline
  haml :timeline
end

get "/tweets" do
  @tweets = current_user.client.user_timeline
  pp @tweets
  haml :timeline
end

get "/mentions" do
  @tweets = current_user.client.mentions
  haml :timeline
end

get "/retweets" do
  @tweets = current_user.client.retweets_of_me
  haml :timeline
end

get "/retweeted" do
  @tweets = current_user.client.retweeted_by_me
  haml :timeline
end

post "/update" do
  current_user.client.update(params[:update])
  redirect '/timeline'
end