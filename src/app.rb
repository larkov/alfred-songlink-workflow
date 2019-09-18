#!/usr/bin/env ruby

require "json"
require "net/http"

country = ENV["country"] || "US"
platforms = (ENV["platforms"] || "").split(",").map(&:strip)

url = ARGV.first.empty? ? `pbpaste` : ARGV.first
uri = "https://api.song.link/v1-alpha.1/links?userCountry=#{country}&url=#{url}"
response = Net::HTTP.get(URI(uri))
parsedResponse = JSON.parse(response);
euid = parsedResponse["entityUniqueId"]
entity = parsedResponse["entitiesByUniqueId"][euid]

out = {
  "items" => [{
    "type" => "default",
    "title" => "#{entity["artistName"]} - #{entity["title"]}",
    "icon" => { "path" => "songlink.png" },
    "valid" => true,
    "subtitle" => parsedResponse["pageUrl"],
    "arg" => parsedResponse["pageUrl"]
  }]
}

parsedResponse["linksByPlatform"].each do |key, value|
  if platforms.include? key
    item = {
      "type" => "default",
      "title" => key,
      "valid" => true,
      "icon" => {
        "path" => File.exist?("#{key}.png") ? "#{key}.png" : "songlink.png"
      },
    }

    if value["nativeAppUriDesktop"]
      item["subtitle"] = value["nativeAppUriDesktop"]
      item["arg"] = value["nativeAppUriDesktop"]
    else
      item["subtitle"] = value["url"]
      item["arg"] = value["url"]
    end

    out["items"].push(item)
  end
end

puts out.to_json
