# README

![Demo](app/assets/images/gif_readme.gif)

Before running the application, you must set the following environment variables for API access at `.env` file:

- `OPEN_WEATHER_API_KEY`: Your OpenWeather API key.
- `GOOGLE_MAPS_API_KEY`: Your Google Maps Geocoding API key.

You can also set these in your terminal session:

```sh
export OPEN_WEATHER_API_KEY=your_openweather_api_key
export GOOGLE_MAPS_API_KEY=your_google_maps_api_key
```

Also it is needed to set cache at rails console to be used locally for development environment:

```sh
bin/rails dev:cache
```
