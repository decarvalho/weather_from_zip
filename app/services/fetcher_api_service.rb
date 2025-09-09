require "net/http"

class FetcherApiService
  def initialize(query)
    @api_weather_key = ENV["OPEN_WEATHER_API_KEY"]
    @api_address_key = ENV["GOOGLE_MAPS_API_KEY"]
    @query = query
  end

  def call
    fetch_weather
  rescue StandardError => e
    Rails.logger.error("Error fetching weather suggestions: #{e.message}")
    []
  end

  private

  def fetch_weather
    url = URI("https://maps.googleapis.com/maps/api/geocode/json?address=#{CGI.escape(@query)}&key=#{@api_address_key}")
    response = Net::HTTP.get(url)
    parsed_location = JSON.parse(response)["results"]
    return [] if parsed_location.size.zero?

    responses = []
    parsed_location.each do |location|
      lat = location["geometry"]["location"]["lat"]
      lon = location["geometry"]["location"]["lng"]
      address_name = location["formatted_address"]
      url = URI("https://api.openweathermap.org/data/2.5/weather?lat=#{lat}&lon=#{lon}&units=metric&appid=#{@api_weather_key}")
      response = Net::HTTP.get(url)
      parsed_response = JSON.parse(response)
      responses << { name: address_name,
                        current_temp: parsed_response["main"]["temp"],
                        min_temp: parsed_response["main"]["temp_min"],
                        max_temp: parsed_response["main"]["temp_max"],
                        requested_time: Time.at(parsed_response["dt"])
                      }
    end

    responses
  end
end
