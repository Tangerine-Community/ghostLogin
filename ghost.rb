# encoding: utf-8
#
# Ghost Login
# Provides a ghostly way of logging in.
##

require 'rubygems'
require 'sinatra'
require 'sinatra/cross_origin'
require "sinatra/cookies"
require 'rest-client'
require 'json'
require 'logger'
require './config.rb'

#
#
#

set :allow_origin, :any
set :allow_methods, [:get, :post, :options]
set :allow_credentials, true
set :max_age, "1728000"
set :protection, :except => :json_csrf

def timestamp
  Time.now.strftime("%Y %b %d %H:%M %Z")
end

def csvResponse (message, redirect = false)
  redirectHtml = "<meta http-equiv=\"refresh\" content=\"0;url=#{redirect}\">" if redirect
  return "<html><head>#{redirectHtml}<style>body { font-family: Helvetica; text-align:center; } h1 { font-size:200px; margin: 20px; color: rgba(0,0,0,0); text-shadow: 0 0 10px rgba(255,255,255,0.5), 0 12px 15px rgba(255,0,0,0.2), -6px -10px 15px rgba(0,255,0,0.2), 6px -10px 15px rgba(0,0,255,0.2); }</style></head><body><h1>#{message}</h1></body></html>"
end

get "/" do 
  csvResponse "ghost", false
end

get "/:user/:pass/*" do | user, pass, location |

  cross_origin

  location.gsub!("localhost","0.0.0.0")
  location.gsub!("http:/0.0.0.0", "http://0.0.0.0") 
 
  cookies[:AuthSession] = authenticate( user, pass )

  redirect location

end


def authenticate (user, pass)

  data    = { :name => user, :password => pass }
  options = { :accept => :json,  :content_type => :json }

  res = RestClient::Resource.new("#{$host}/_session", user, pass)

  restResponse = res.post data.to_json, options

  sessionResponse = JSON.parse(restResponse)

  #generally, we just need to return the cookie. This login is only ever performed automatically.

  return restResponse.cookies["AuthSession"]

end
