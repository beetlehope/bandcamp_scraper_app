require 'mechanize'
require 'nokogiri'
require 'active_record'

# Connects to the database.
ActiveRecord::Base.establish_connection(
    :adapter  => 'postgresql',
    :host     => 'localhost',
    :username => 'bandcamp',
    :password => 'bandcamp',
    :database => 'bandcamp_app_development')

# This class is used to save information about albums with Creative Commons license into the database.
class Album < ActiveRecord::Base
end

current_page = 1
total_pages = 2472 # Total number comes from this catalogue https://bandcamp.com/artist_index?page=9&sort_asc=1

while current_page < total_pages do

    agent = Mechanize.new
    agent.history.max_size = 0

    # Opens the page where scraping starts.
    page = agent.get("https://bandcamp.com/artist_index?page=#{current_page}&sort_asc=1")

    # Specifies the pattern shared by links to individual album pages.
    album_links = page.links_with(:href => /bandcamp.com$/).drop(1) # Drops www.bandcamp.com

    # Specifies the pattern shared by links to discographies.
    discography_links = (album_links.map{|link| "#{link.href}" + "/music"})

    discography_links.map do |discography_link|
      agent = Mechanize.new
      agent.history.max_size = 0

      # Opens the page with an artist's discography, catches errors.
      begin
        discography_page = agent.get(discography_link)
      rescue Mechanize::ResponseCodeError, OpenSSL::SSL::SSLError, Errno::EMFILE, SocketError, Net::HTTPServiceUnavailable, Net::HTTPNotFound, Errno::ECONNRESET, Net::OpenTimeout => e
        puts e
        puts "Caught an error, will wait 100 seconds and try again!"
        sleep(100)
        retry
      end

        # Checks whether the opened page contains the word 'realeased'. If yes, it means we've been redirected to a '.../releases' 
        # page, which means this artist has only one album or track. 
        # Consequently the script has to scrape just one page for this artist.

        if discography_page.css("div.tralbumData.tralbum-credits").text.include? 'released'
          
            # Specifies Album model attributes that need to be saved into the database.
            license_info = discography_page.css("div#license.info.license").text
            license_link =  discography_page.at_css("#license.info.license a")
            license_link_value =  discography_page.at_css("#license.info.license a")[:href] if license_link
            title = discography_page.at_css("div#name-section h2.trackTitle").text if discography_page.at_css("div#name-section h2.trackTitle")
            artist = discography_page.css("p#band-name-location span.title").text
            release_date = discography_page.css("div.tralbumData.tralbum-credits").text.sub(/(\s+\d\d\d\d\s+).*/mi, "\\1")
            description = ""
            description = discography_page.at_css("div.tralbumData.tralbum-about").text if discography_page.at_css("div.tralbumData.tralbum-about")
            link = discography_page.uri
            tags = ""
            tags = discography_page.css("div.tralbumData.tralbum-tags.tralbum-tags-nu a").map(&:text)
            tags.map!(&:strip)
            image_src = ""
            image_src = discography_page.at_css("a.popupImage")[:href] if discography_page.at_css("a.popupImage")

                # Checks whether the page containts a link to a license page. Only albums with Creative Commons licenses have such 
                # links, consequently they need to be saved into the database. Otherwise the script just logs out some info about the # artist. 
                if license_link

                    case license_link_value
                    when "http://creativecommons.org/licenses/by/3.0/"
                          Album.create(:license_type => "Commercial use & mods allowed", :title => "#{title}", :artist => "#{artist}", :release_date => "#{release_date}", :description => "#{description}", :link => "#{link}", :tags => tags, :image_src => "#{image_src}")

                    when "http://creativecommons.org/licenses/by-sa/3.0/"
                          Album.create(:license_type => "Commercial use & mods allowed", :title => "#{title}", :artist => "#{artist}", :release_date => "#{release_date}", :description => "#{description}", :link => "#{link}", :tags => tags, :image_src => "#{image_src}")

                    when "http://creativecommons.org/licenses/by-nd/3.0/"
                          Album.create(:license_type => "Commercial use allowed", :title => "#{title}", :artist => "#{artist}", :release_date => "#{release_date}", :description => "#{description}", :link => "#{link}", :tags => tags, :image_src => "#{image_src}")

                    when "http://creativecommons.org/licenses/by-nc/3.0/"
                          Album.create(:license_type => "Modifications allowed", :title => "#{title}", :artist => "#{artist}", :release_date => "#{release_date}", :description => "#{description}", :link => "#{link}", :tags => tags, :image_src => "#{image_src}")

                    when "http://creativecommons.org/licenses/by-nc-sa/3.0/"
                          Album.create(:license_type => "Modifications allowed", :title => "#{title}", :artist => "#{artist}", :release_date => "#{release_date}", :description => "#{description}", :link => "#{link}", :tags => tags, :image_src => "#{image_src}")

                    when "http://creativecommons.org/licenses/by-nc-nd/3.0/"
                          Album.create(:license_type => "Non-commercial use only & no mods allowed", :title => "#{title}", :artist => "#{artist}", :release_date => "#{release_date}", :description => "#{description}", :link => "#{link}", :tags => tags, :image_src => "#{image_src}")

                    end

                else
                    puts "#{artist} has just one album or track under #{license_info}"
                end
        # If the page doesn't contain the word 'realeased', it means this artist has multiple albums or tracks. Consequently we 
        # have to scrape each individual album/track page.          
        else

                
            # Specifies the pattern shared by links to individul album pages.              
            disc_links = discography_page.links_with(:href => /^\/album\/|^\/track\//)


            disc_links.map do |disc_link|
              # Opens each album's page, catches errors.  
              begin
                  disc_page = disc_link.click
              rescue Mechanize::ChunkedTerminationError, Mechanize::ResponseCodeError, OpenSSL::SSL::SSLError, Errno::EMFILE, SocketError, Net::HTTPServiceUnavailable,  Net::HTTPNotFound => e
                  puts e
                  puts "Caught an error, will wait 100 seconds and try again!"
                  sleep(100)
              retry

              end

            # Specifies Album model attributes
            license_info = disc_page.css("div#license.info.license").text
            license_link =  disc_page.at_css("#license.info.license a")
            license_link_value =  disc_page.at_css("#license.info.license a")[:href] if license_link
            title = disc_page.at_css("div#name-section h2.trackTitle").text if disc_page.at_css("div#name-section h2.trackTitle")
            artist = disc_page.css("p#band-name-location span.title").text
            release_date = disc_page.css("div.tralbumData.tralbum-credits").text.sub(/(\s+\d\d\d\d\s+).*/mi, "\\1")
            description = ""
            description = disc_page.at_css("div.tralbumData.tralbum-about").text if disc_page.at_css("div.tralbumData.tralbum-about")
            link = disc_page.uri
            tags = disc_page.css("div.tralbumData.tralbum-tags.tralbum-tags-nu a").map(&:text)
            tags.map!(&:strip)
            image_src = ""
            image_src = disc_page.at_css("a.popupImage")[:href] if disc_page.at_css("a.popupImage")


              # Checks if there is a link to a license page and acts accordingly: either saves the album into the database or logs 
              # out information.
              if license_link
                case license_link_value
                when "http://creativecommons.org/licenses/by/3.0/"
                      Album.create(:license_type => "Commercial use & mods allowed", :title => "#{title}", :artist => "#{artist}", :release_date => "#{release_date}", :description => "#{description}", :link => "#{link}", :tags => tags, :image_src => "#{image_src}")

                when "http://creativecommons.org/licenses/by-sa/3.0/"
                      Album.create(:license_type => "Commercial use & mods allowed", :title => "#{title}", :artist => "#{artist}", :release_date => "#{release_date}", :description => "#{description}", :link => "#{link}", :tags => tags, :image_src => "#{image_src}")

                when "http://creativecommons.org/licenses/by-nd/3.0/"
                      Album.create(:license_type => "Commercial use allowed", :title => "#{title}", :artist => "#{artist}", :release_date => "#{release_date}", :description => "#{description}", :link => "#{link}", :tags => tags, :image_src => "#{image_src}")

                when "http://creativecommons.org/licenses/by-nc/3.0/"
                      Album.create(:license_type => "Modifications allowed", :title => "#{title}", :artist => "#{artist}", :release_date => "#{release_date}", :description => "#{description}", :link => "#{link}", :tags => tags, :image_src => "#{image_src}")

                when "http://creativecommons.org/licenses/by-nc-sa/3.0/"
                      Album.create(:license_type => "Modifications allowed", :title => "#{title}", :artist => "#{artist}", :release_date => "#{release_date}", :description => "#{description}", :link => "#{link}", :tags => tags, :image_src => "#{image_src}")

                when "http://creativecommons.org/licenses/by-nc-nd/3.0/"
                      Album.create(:license_type => "Non-commercial use only & no mods allowed", :title => "#{title}", :artist => "#{artist}", :release_date => "#{release_date}", :description => "#{description}", :link => "#{link}", :tags => tags, :image_src => "#{image_src}")

                end


              else
                  puts "#{artist} #{title} #{license_info} #{current_page}"
              end
            end
        end

    end

    agent.history.clear

    # Goes to the next page in the artists' catalogue
    current_page += 1

end
