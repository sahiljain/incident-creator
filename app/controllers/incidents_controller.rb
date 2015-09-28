require 'httparty'
require 'faker'

class IncidentsController < ApplicationController
  include HTTParty

  format :json
  headers 'Accept' => 'application/json'

  def generate_incident

    random_error =  File.readlines('app/controllers/error_codes.txt').sample.strip
    random_client = File.readlines('app/controllers/clients.txt').sample.strip
    random_gif = File.readlines('app/controllers/gifs.txt').sample.strip

    { :service_key => params[:serviceKey],
              :event_type => 'trigger',
              :description => random_error,
              :client => random_client,
              :client_url => 'http://www.google.com/search?btnI&q=' + random_client,
              :contexts => [
                  {
                      'href' => 'http://www.pagerduty.com',
                      'type' => 'link',
                      'text' => 'Incident Report'
                  },
                  {
                      'type' => 'image',
                      'src' => random_gif
                  }
              ],
              :details => {
                  :body => 'Encountered the following system error: ' + random_error,
                  :priority => 'elevated',
                  :event_type => 'metric_alert_monitor',
                  :title => 'Error from monitoring service: ' + random_client,
                  :org => 'PagerDuty Inc.',
                  :ip_addr => Faker::Internet.ip_v4_address,
              }
    }.to_json
  end

  def create
    Thread.new do
      (1..params[:numberIncidents].to_i).each { |_|
        self.class.post('https://events.pagerduty.com/generic/2010-04-15/create_event.json', {:body => generate_incident})
      }
    end
  end
end
