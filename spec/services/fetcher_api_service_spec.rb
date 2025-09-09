require 'rails_helper'

RSpec.describe FetcherApiService, type: :service do
  let(:query) { "New York" }
  let(:service) { described_class.new(query) }

  before do
    # Set fake ENV vars for testing
    stub_const("ENV", ENV.to_hash.merge(
      "OPEN_WEATHER_API_KEY" => "fake_weather_key",
      "GOOGLE_MAPS_API_KEY" => "fake_maps_key"
    ))
  end

  describe "#call" do
    context "when API returns valid data" do
      let(:geocode_response) do
        {
          results: [
            {
              "geometry" => { "location" => { "lat" => 40.7128, "lng" => -74.0060 } },
              "formatted_address" => "New York, NY, USA"
            }
          ]
        }.to_json
      end

      let(:weather_response) do
        {
          "main" => { "temp" => 20, "temp_min" => 18, "temp_max" => 22 },
          "dt" => 1_700_000_000
        }.to_json
      end

      before do
        allow(Net::HTTP).to receive(:get).and_return(geocode_response, weather_response)
      end

      it "returns an array of weather data hashes" do
        result = service.call
        expect(result).to be_an(Array)
        expect(result.first[:name]).to eq("New York, NY, USA")
        expect(result.first[:current_temp]).to eq(20)
        expect(result.first[:min_temp]).to eq(18)
        expect(result.first[:max_temp]).to eq(22)
        expect(result.first[:requested_time]).to be_a(Time)
      end
    end

    context "when geocode API returns no results" do
      before do
        allow(Net::HTTP).to receive(:get).and_return({ results: [] }.to_json)
      end

      it "returns an empty array" do
        expect(service.call).to eq([])
      end
    end

    context "when an error occurs" do
      before do
        allow(Net::HTTP).to receive(:get).and_raise(StandardError, "API error")
      end

      it "logs the error and returns an empty array" do
        expect(Rails.logger).to receive(:error).with(/Error fetching weather suggestions: API error/)
        expect(service.call).to eq([])
      end
    end
  end
end
