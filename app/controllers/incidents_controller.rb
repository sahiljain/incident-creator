require 'httparty'
require 'faker'

class IncidentsController < ApplicationController
  include HTTParty

  format :json
  headers 'Accept' => 'application/json'

  def create
    puts "service key is " + params[:serviceKey]
    puts "number of incidents is " + params[:numberIncidents]
    stuff = { :service_key => params[:serviceKey],
      :event_type => 'trigger',
      :description => 'butts',
      :contexts => [
          {
              'href' => 'http://www.pagerduty.com',
              'type' => 'link',
              'text' => 'Incident Report'
          },
          {
              'type' => 'image',
              'src' => 'https://chart.googleapis.com/chart?chs=451x180&chd=t:1,2,3,5,8,13,7&cht=lc&chds=a&chxt=y&chm=D,0033FF,0,0,5,1%22'
          }
      ],
      :details => {
          :mac_address => Faker::Internet.mac_address,
          :ip_addr => Faker::Internet.ip_v4_address,
          :quote => "this is a quote"
      }
    }.to_json

    Thread.new do
      for i in 1..params[:numberIncidents].to_i
        self.class.post('https://events.pagerduty.com/generic/2010-04-15/create_event.json', { :body => stuff })
      end
    end
  end
end
