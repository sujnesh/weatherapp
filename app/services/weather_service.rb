class WeatherService

  # Fetches and processes weather data for a given location
  # @param location [String] the location to fetch weather data for
  # @return [Array] an array containing the weather data, a boolean indicating if the data was cached, and the weather code status
  def self.fetch_and_process_data(location)
    weather_data, weather_data_cached = fetch_weather_data(location) # Fetch weather data, determine if it was cached
    weather_code_status = Constants::WEATHER_CODE[weather_data.dig("data", "values", "weatherCode").to_s] # Map weather code to status
    [weather_data, weather_data_cached, weather_code_status] # Return the fetched data, cache status, and weather code status
  end

  private

  # Fetches weather data from cache or external API
  # @param location [String] the location to fetch weather data for
  # @return [Array] an array containing the weather data and a boolean indicating if the data was cached
  def self.fetch_weather_data(location)
    return [[], false] if location.blank? # Return empty data if location is blank
    weather_data_cached = true # Assume data is cached initially
    weather_data = Rails.cache.fetch(location, expires_in: 30.minutes) do # Fetch data from cache or external API
      weather_data_cached = false # Set to false if data is not found in cache and needs to be fetched from external API
      ExternalApis.fetch_weather(location) # Fetch data from external API
    end
    [weather_data, weather_data_cached] # Return the fetched data and cache status
  end
end
