#!/usr/bin/env ruby
require 'json'

url = `pbpaste`
query = ARGV[0]
icon = "icon.png"

out = Hash.new

out['items'] = [{"type" => "default", "title" => "song.link url", "icon" => { "path" => icon }, "subtitle" => "https://song.link/#{url}", "arg" => "" }]

print out.to_json