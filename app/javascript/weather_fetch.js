"use strict";

document.addEventListener('DOMContentLoaded', function() {
  var searchInput = document.getElementById('query');
  var suggestionsDiv = document.getElementById('suggestions');
  var isFetching = false;

  var typingTimer;
  var doneTypingInterval = 800;

  // on keyup, start the countdown
  searchInput.addEventListener('keyup', function() {
    clearTimeout(typingTimer);
    if (searchInput.value) {
      typingTimer = setTimeout(fetchSuggestions, doneTypingInterval);
    }
  });

  var fetchSuggestions = (async function() {
    var query = searchInput.value;
    if (isFetching) {
      return;
    }

    if (query.length > 2) {
      isFetching = true;
      try {
        suggestionsDiv.innerHTML = '';
        var loadingItem = document.createElement('div');
        loadingItem.textContent = `Loading weather for address = ${query}...`;
        suggestionsDiv.appendChild(loadingItem);
        var response = await fetch(`/suggestions?query=${query}`);
        if (Array.isArray(response) && response.length === 0) {
          suggestionsDiv.innerHTML = `No place found for ${query}. :(`;
        } else if (Array.isArray(response) && response.length > 0) {
          var suggestions = response.json();
          suggestionsDiv.innerHTML = '';
          var dataSource = suggestions.pop();
          loadingItem.textContent = `${dataSource}`;
          suggestionsDiv.appendChild(loadingItem);
          suggestions.forEach(function(suggestion) {
            var suggestionItem = document.createElement('div');
            suggestionItem.textContent = `Name: ${suggestion.name},
                                          Current Temperature: ${suggestion.current_temp},
                                          Min Temperature: ${suggestion.min_temp},
                                          Max Temperature: ${suggestion.max_temp},
                                          Requested Time: ${suggestion.requested_time}`;
            suggestionsDiv.appendChild(suggestionItem);
          });
        }
      } catch {
        suggestionsDiv.innerHTML = '';
      } finally {
        isFetching = false;
      }
    } else {
      suggestionsDiv.innerHTML = '';
    }
  });
});