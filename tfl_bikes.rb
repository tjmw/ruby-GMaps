require 'rubygems'
require 'sinatra/base'
require 'net/http'
require 'uri'
require 'rexml/document'

class TFLBikes < Sinatra::Base

    attr_reader :tfl_bike_data

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

        @tfl_bike_data = stations

        haml :tfl_bikes_kml
    end
end
