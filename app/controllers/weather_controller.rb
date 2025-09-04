require "net/http"
class WeatherController < ApplicationController
  def index
  end

  def suggestions
    if params[:query].present?
      response = fetch_weather_suggestions(params[:query])
      render json: response
    else
      render json: []
    end
  end

  private

  def fetch_weather_suggestions(query)
    api_weather_key = ENV["OPEN_WEATHER_API_KEY"]
    api_address_key = ENV["GOOGLE_MAPS_API_KEY"]
    api_hash = []
    data = Rails.cache.fetch(query, expires_in: 30.minutes) do
      url = URI("https://maps.googleapis.com/maps/api/geocode/json?address=#{CGI.escape(query)}&key=#{api_address_key}")
      response = Net::HTTP.get(url)
      parsed_location = JSON.parse(response)["results"]
      return [] if parsed_location.size.zero?

      if parsed_location.size >= 1
        parsed_location.each do |location|
          lat = location["geometry"]["location"]["lat"]
          lon = location["geometry"]["location"]["lng"]
          address_name = location["formatted_address"]
          url = URI("https://api.openweathermap.org/data/2.5/weather?lat=#{lat}&lon=#{lon}&units=metric&appid=#{api_weather_key}")
          response = Net::HTTP.get(url)
          parsed_response = JSON.parse(response)
          api_hash << { name: address_name,
                            current_temp: parsed_response["main"]["temp"],
                            min_temp: parsed_response["main"]["temp_min"],
                            max_temp: parsed_response["main"]["temp_max"],
                            requested_time: Time.at(parsed_response["dt"])
                          }
        end
      else
        url = URI("https://api.openweathermap.org/data/2.5/weather?lat=#{parsed_location["lat"]}&lon=#{parsed_location["lon"]}&units=metric&appid=#{api_weather_key}")
        response = Net::HTTP.get(url)
        parsed_response = JSON.parse(response)
        api_hash << { name: address_name,
                          country: parsed_response["country"],
                          state: parsed_response["state"],
                          current_temperature: parsed_response["main"]["temp"],
                          min_temperature: parsed_response["main"]["temp_min"],
                          max_temperature: parsed_response["main"]["temp_max"],
                          requested_time: Time.at(parsed_response["dt"])
                        }
      end
      api_hash
  end
  return data.push(:cache_hit) if api_hash.blank?

  data.push(:api_hit)

  rescue StandardError => e
    Rails.logger.error("Error fetching weather suggestions: #{e.message}")
    []
  end
end
