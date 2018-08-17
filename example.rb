#!/usr/bin/ruby
require './top_to_json.rb'

TopToJSON.new.parse do |top|
  puts top[:memory]
end

top = TopToJSON.new.parse

puts top.to_json
