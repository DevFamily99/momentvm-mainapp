require "uri"
require "net/http"
require "json"



require "redis"

module MemoryHelper

  
  def write
    redis = Redis.new
    redis.set("Test", "testt test")
    puts "hello"
    return true
  end


  def read
    redis = Redis.new
    puts redis.get("Test")
    return true
  end


end
