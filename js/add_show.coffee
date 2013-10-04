$("#venue").typeahead({
  source: (query, process) ->
    return $.get "#{api_url}/api/v1/venue/", { "name__icontains": query }, (data) ->
      options = []
      for venue in data.objects
        options.push(venue["name"])
      return process(options)
  updater: (item) ->
    console.log(item)
})
