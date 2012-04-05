require 'rubygems'
require 'sinatra/base'
require 'net/http'
require 'uri'
require 'csv'
require 'rexml/document'

class GMaps < Sinatra::Base
    set :root, File.dirname(__FILE__)

    get '/bikes' do
          File.read(File.join('public', 'bikes.html'))
    end

    get '/allotments' do
          File.read(File.join('public', 'allotments.html'))
    end

    get '/tfl_bikes.kml' do
        content_type 'text/xml'

        tfl_url = URI.parse("http://dl.dropbox.com/u/6313902/livecyclehire-example.txt")

        tfl_xml = REXML::Document.new(
            Net::HTTP.get_response(tfl_url).body
        )

        stations = []

        tfl_xml.elements.each('//stations/station') do |station|
            station_data = {}

            station_data['name']        = station.get_text('name')
            station_data['description'] = station.get_text('terminalName')
            station_data['lat']         = station.get_text('lat')
            station_data['long']        = station.get_text('long')

            stations << station_data
        end

        haml :kml,
            :locals => {
                :data => stations,
                :icon => 'http://freezing-winter-3097.heroku.com/cycle-hire-pushpin-icon.gif'
            }
    end

    get '/allotments.kml' do
        content_type 'text/xml'

        allotments_url = URI.parse("http://dl.dropbox.com/u/6313902/gla-allotment-locations.csv")

        allotments_csv = CSV::Reader.parse(
            Net::HTTP.get_response(allotments_url).body
        )
        
        allotments = []
        
        # lose the headers
        allotments_csv.shift
        
        allotments_csv.each do |row|
            allotment_data = {}

            allotment_data['name']        = row[2]
            allotment_data['description'] = row[3]
            allotment_data['lat']         = row[13]
            allotment_data['long']        = row[14]

            allotments << allotment_data
        end

        haml :kml,
            :locals => {
                :data => allotments,
                :icon => 'http://freezing-winter-3097.heroku.com/cycle-hire-pushpin-icon.gif'
            }
    end
end
