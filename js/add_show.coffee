venue_map = {}

$("#venue_text").typeahead({
  source: (query, process) ->
    options = []
    $.get "#{api_url}/api/v1/venue/", { "name__icontains": query }, (data) ->
      for venue in data.objects
        venue_map[venue["name"]] = venue["id"]
        options.push(venue["name"])
      return process(options)
  updater: (venue_name) ->
    venue_id = venue_map[venue_name]
    $("#venue_text").hide()
    $("#venue_selected")
      .text(venue_name)
      .attr("data-id", venue_id)
      .click () ->
        $("#venue_selected").text('').attr("data-id", '').hide()
        $("#venue_text").val(venue_name).show()
      .show()
})
