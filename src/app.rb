#!/usr/bin/env ruby
require 'json'
require 'httparty'

country = ENV['country'] || "SE"
platforms = ENV['platforms'].split(",").map(&:strip)
# platforms = "appleMusic, spotify, google"

url = `pbpaste`
# url = "https://music.apple.com/se/album/caligula/1463453125?l=en"
uri = "https://api.song.link/v1-alpha.1/links?userCountry=#{country}&url=#{url}"

response=HTTParty.get(uri)
parsedResponse = JSON.parse(response.to_s);
euid = parsedResponse["entityUniqueId"]

out = Hash.new
out['items'] = [{"type" => "default",
    "title" => "#{parsedResponse["entitiesByUniqueId"][euid]["artistName"]} - #{parsedResponse["entitiesByUniqueId"][euid]["title"]}",
    "icon" => { "path" => "songlink.png" },
    "valid" => true,
    "subtitle" => "#{parsedResponse["pageUrl"]}",
    "arg" => "#{parsedResponse["pageUrl"]}" }]

parsedResponse["linksByPlatform"].each{|key,value|
    if platforms.include? key 
        item = {"type" => "default",
        "title" => "#{key}",
        "valid" => true}

        if File.exist?("#{key}.png")
            item["icon"] = { "path" => "#{key}.png" }
        else
            item["icon"] = { "path" => "songlink.png" }
        end

        if value["nativeAppUriDesktop"]
            item["subtitle"]="#{value["nativeAppUriDesktop"]}"
            item["arg"]="#{value["nativeAppUriDesktop"]}"
            # puts "#{key} #{value["nativeAppUriDesktop"]}"
        else
            item["subtitle"]="#{value["url"]}"
            item["arg"]="#{value["url"]}"
            # puts "#{key} #{value["url"]}"
        end
        out["items"].push(item)
    end
}


print out.to_json