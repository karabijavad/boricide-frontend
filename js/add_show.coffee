venue_map = {}

$("#venue").typeahead({
  source: (query, process) ->
    options = []
    $.get "#{api_url}/api/v1/venue/", { "name__icontains": query }, (data) ->
      for venue in data.objects
        venue_map[venue["name"]] = venue["id"]
        options.push(venue["name"])
      return process(options)
  updater: (item) ->
    venue_id = venue_map[item]
})
