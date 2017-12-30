require 'mechanize'
require 'nokogiri'
require 'active_record'

ActiveRecord::Base.establish_connection(
    :adapter  => 'postgresql',
    :host     => 'localhost',
    :username => 'bandcamp',
    :password => 'bandcamp',
    :database => 'bandcamp_app_development')

# Start of scraping
agent = Mechanize.new
pages_count = 15
while pages_count < 17 do
    page = agent.get('https://bandcamp.com/artist_index?page="#{pages_count}"')
    albums_links = page.links_with(href: %r{bandcamp.com$|bandcamp.com/releases$})
    albums_links = albums_links[0..10]

    albums_links.map do |link|
    album_page = link.click

#Assigning model attributes to variables

    license_info = album_page.css("div#license.info.license").text
    license_link =  album_page.at_css("#license.info.license a")
    license_link_value =  album_page.at_css("#license.info.license a")[:href] if license_link

    title = album_page.at_css("div#name-section h2.trackTitle").text if album_page.at_css("div#name-section h2.trackTitle")
    artist = album_page.css("p#band-name-location span.title").text
    release_date = album_page.css("div.tralbumData.tralbum-credits").text.sub(/(\s+\d\d\d\d\s+).*/mi, "\\1")
    description = album_page.at_css("div.tralbumData.tralbum-about").text if album_page.at_css("div.tralbumData.tralbum-about")
    link = album_page.uri
    tags = album_page.css("div.tralbumData.tralbum-tags.tralbum-tags-nu a").text #this is of type array in db
    image_src = album_page.at_css("a.popupImage")[:href] if album_page.at_css("a.popupImage")

# Building an Album class for saving info into database

class Album < ActiveRecord::Base
end

# Parsing each opened page to see whether license link is present, if it is, the scrips grabs info about this album and stores it in the db
if license_link


  case license_link_value
  when "http://creativecommons.org/licenses/by/3.0/"
        Album.create(:license_type => "Attribution 3.0 International (CC BY 3.0)", :title => "#{title}", :artist => "#{artist}", :release_date => "#{release_date}", :description => "#{description}", :link => "#{link}", :tags => "#{tags}", :image_src => "#{image_src}")

  when "http://creativecommons.org/licenses/by-sa/3.0/"
        Album.create(:license_type => "Attribution-ShareAlike 3.0 International (CC BY-SA 3.0)", :title => "#{title}", :artist => "#{artist}", :release_date => "#{release_date}", :description => "#{description}", :link => "#{link}", :tags => "#{tags}", :image_src => "#{image_src}")

  when "http://creativecommons.org/licenses/by-nd/3.0/"
        Album.create(:license_type => "Attribution-NoDerivatives 3.0 International (CC BY-ND 3.0)", :title => "#{title}", :artist => "#{artist}", :release_date => "#{release_date}", :description => "#{description}", :link => "#{link}", :tags => "#{tags}", :image_src => "#{image_src}")

  when "http://creativecommons.org/licenses/by-nc/3.0/"
        Album.create(:license_type => "Attribution-NonCommercial 3.0 International (CC BY-NC 3.0)", :title => "#{title}", :artist => "#{artist}", :release_date => "#{release_date}", :description => "#{description}", :link => "#{link}", :tags => "#{tags}", :image_src => "#{image_src}")

  when "http://creativecommons.org/licenses/by-nc-sa/3.0/"
        Album.create(:license_type => "Attribution-NonCommercial-ShareAlike 3.0 International (CC BY-NC-SA 3.0)", :title => "#{title}", :artist => "#{artist}", :release_date => "#{release_date}", :description => "#{description}", :link => "#{link}", :tags => "#{tags}", :image_src => "#{image_src}")

  when "http://creativecommons.org/licenses/by-nc-nd/3.0/"
        Album.create(:license_type => "Attribution-NonCommercial-NoDerivatives 3.0 International (CC BY-NC-ND 3.0)", :title => "#{title}", :artist => "#{artist}", :release_date => "#{release_date}", :description => "#{description}", :link => "#{link}", :tags => "#{tags}", :image_src => "#{image_src}")

  end

else
    puts "#{license_info}"

end

pages_count += 1
end
end

# Implementing random time interval between parsing loops

#def rand_int(from, to)
#  rand_in_range(from, to).to_i
#end

#def rand_in_range(from, to)
#  rand * (to - from) + from
#end
#    sleep(rand_int(1, 10))
