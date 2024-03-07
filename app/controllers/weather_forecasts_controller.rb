class WeatherForecastsController < ApplicationController
  before_action :validate_params, only: [:show]

  def index
    if params[:location].present?
      redirect_to action: :show, location: params[:location]
    else
      # Default to New York's zip code
      redirect_to action: :show, location: '10281'
    end
  end

  def show
    @location = params[:location]
    @weather_data, @weather_data_cached, @weather_code_status = WeatherService.fetch_and_process_data(@location)
    forecast_data = WeatherForecastService.fetch_and_process_data(@location)
    @specific_weather_data_cached = forecast_data[:specific_weather_data_cached]
    @max_temperature = forecast_data[:max_temperature]
    @min_temperature = forecast_data[:min_temperature]
    @daily_weather_data = forecast_data[:specific_weather_data]["timelines"]["daily"]
    render 'show'
  end

  private

  def validate_params
    unless params[:location].present?
      redirect_to root_path, alert: 'Location parameter is missing'
    end
  end
end
