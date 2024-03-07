Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: 'weather_forecasts#index'
  get '/weather_forecasts/:location', to: 'weather_forecasts#show'
  get '/weather_forecasts', to: 'weather_forecasts#index'
end
``
