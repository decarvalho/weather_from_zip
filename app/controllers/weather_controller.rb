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
      api_hash = FetcherApiService.new(query).call
      api_hash
    end
    return [] if data.blank? && api_hash.blank?

    return data.push(:cache_hit) if api_hash.blank?

    data.push(:api_hit)

  rescue StandardError => e
    Rails.logger.error("Error fetching weather suggestions: #{e.message}")
    []
  end
end
