require 'httparty'

class ExternalApis
  def self.fetch_weather(location)
    api_key = ENV['WEATHER_API_KEY']
    url = build_url("https://api.tomorrow.io/v4/weather/realtime", location: location, apikey: api_key)
    make_get_request(url)
  end

  def self.fetch_weather_forecast(location)
    api_key = ENV['WEATHER_API_KEY']
    url = build_url("https://api.tomorrow.io/v4/weather/forecast", location: location, apikey: api_key)
    make_get_request(url)
  end

  private

  def self.build_url(base_url, params)
    URI(base_url).tap do |uri|
      uri.query = URI.encode_www_form(params)
    end.to_s
  end

  def self.make_get_request(url)
    response = HTTParty.get(url)
    parse_response(response)
  rescue StandardError => e
    Rails.logger.error "Failed to fetch data from external API: #{e.message}"
    []
  end

  def self.parse_response(response)
    if response.code == 200
      JSON.parse(response.body)
    else
      Rails.logger.error "External API returned non-success status code: #{response.code}"
      []
    end
  end
end
