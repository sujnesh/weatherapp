class WeatherForecastService
  # Fetches and processes weather data for a given location
  def self.fetch_and_process_data(location)
    # Fetch weather forecast data and check if it was retrieved from cache
    specific_weather_data, specific_weather_data_cached = fetch_weather_forecast(location)
    # Calculate maximum and minimum temperatures from the weather data
    max_temperature, min_temperature = calc_max_min_temp(specific_weather_data)
    # Return a hash containing the weather data, cache status, max/min temperatures, and daily weather data
    {
      specific_weather_data: specific_weather_data,
      specific_weather_data_cached: specific_weather_data_cached,
      max_temperature: max_temperature,
      min_temperature: min_temperature,
      daily_weather_data: specific_weather_data["timelines"]["daily"],
    }
  end

  private
  # Fetches weather forecast data from cache or external API based on location
  def self.fetch_weather_forecast(location)
    # Return empty data if location is not provided
    return [[], false] if location.blank?
    # Generate a cache key based on location
    cache_key = "weather_forecast_#{location}"
    specific_weather_data_cached = true
    # Attempt to fetch weather data from cache, or call external API if not found
    specific_weather_data = Rails.cache.fetch(cache_key, expires_in: 30.minutes) do
      specific_weather_data_cached = false
      ExternalApis.fetch_weather_forecast(location)
    end
    [specific_weather_data, specific_weather_data_cached]
  end

  # Calculates the maximum and minimum temperatures for the current day from the weather data
  def self.calc_max_min_temp(specific_weather_data)
    # Return default temperatures if weather data is missing
    return [0, 0] if specific_weather_data.blank?
    # Extract hourly forecasts from the weather data
    hourly_forecasts = specific_weather_data["timelines"]["hourly"]
    # Filter forecasts for the current day
    today_forecasts = hourly_forecasts.select do |forecast|
      forecast_time = forecast["time"].to_time.utc.to_date
      forecast_time == Date.today
    end
    # Extract temperatures from today's forecasts
    today_temperatures = today_forecasts.map { |forecast| forecast["values"]["temperature"] }
    # Find the maximum and minimum temperatures
    max_temperature = today_temperatures.max
    min_temperature = today_temperatures.min
    [max_temperature, min_temperature]
  end
end
