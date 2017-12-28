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
pages_count = 1
while pages_count < 2433 do
    page = agent.get('https://bandcamp.com/artist_index?page=/#{pages_count}')
    albums_links = page.links_with(href: %r{bandcamp.com$|bandcamp.com/releases$})
    albums_links = albums_links[0..30]

albums_links.map do |link|
  album_page = link.click

  license_link =  album_page.at_css("#license.info.license a")
  license_link_value =  album_page.at_css("#license.info.license a")[:href] if license_link

# Building an Album class for saving info into database

class Album < ActiveRecord::Base
  #attr_accessor :license_type
end



# Parsing each opened page to see whether license link is present, if it is, the scrips grabs info about this album and stores it in the db
if license_link


      case license_link_value
      when "http://creativecommons.org/licenses/by/3.0/"
        #should save info about this album into database instead of loggin out
         #puts "Attribution 3.0 International (CC BY 3.0)"
         @album = Album.new
         @album.license_type = license_link_value
         @album.save

      when "http://creativecommons.org/licenses/by-sa/3.0/"
          #puts "Attribution-ShareAlike 3.0 International (CC BY-SA 3.0)"
          @album = Album.new
          @album.license_type = license_link_value
          @album.save

      when "http://creativecommons.org/licenses/by-nd/3.0/"
        #puts "Attribution-NoDerivatives 3.0 International (CC BY-ND 3.0)"
        @album = Album.new
        @album.license_type = license_link_value
        @album.save

      when "http://creativecommons.org/licenses/by-nc/3.0/"
        #puts "Attribution-NonCommercial 3.0 International (CC BY-NC 3.0)"
        @album = Album.new
        @album.license_type = license_link_value
        @album.save

      when "http://creativecommons.org/licenses/by-nc-sa/3.0/"
        #puts "Attribution-NonCommercial-ShareAlike 3.0 International (CC BY-NC-SA 3.0)"
        @album = Album.new
        @album.license_type = license_link_value
        @album.save

      when "http://creativecommons.org/licenses/by-nc-nd/3.0/"
        #puts "Attribution-NonCommercial-NoDerivatives 3.0 International (CC BY-NC-ND 3.0)"
        @album = Album.new
        @album.license_type = license_link_value
        @album.save
      end

else
    puts "All rights reserved"
end

end



# Implementing random time interval between parsing loops

def rand_int(from, to)
  rand_in_range(from, to).to_i
end

def rand_in_range(from, to)
  rand * (to - from) + from
end
    sleep(rand_int(10, 50))

  # Go to the next page on artists index

    pages_count = pages_count + 1

end
