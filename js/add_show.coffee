venue_map = {}

$("#venue_text").typeahead({
  source: (query, process) ->
    options = []
    $.get "#{api_url}/api/v1/venue/", { "name__icontains": query, "username": username, "api_key": apikey }, (data) ->
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

artist_map = {}

$("#artist_text").typeahead({
  source: (query, process) ->
    options = []
    $.get "#{api_url}/api/v1/artist/", {"name__icontains": query, "username": username, "api_key": apikey}, (data) ->
      for artist in data.objects
        artist_map[artist["name"]] = artist["id"]
        options.push(artist["name"])
      return process(options)
  updater: (artist_name) ->
    artist_id = artist_map[artist_name]
    if not $("#artists_selected > [data-id=#{artist_id}]").length
      $("<span class='btn btn-success btn-lg' data-id='#{artist_id}'>#{artist_name}</span>")
        .appendTo("#artists_selected")
        .click () -> $(this).remove()
    return ''
})

$('#newshow_daterange').daterangepicker(
    {
      timePicker: true,
      ranges: {},
    },
    (start, end) ->
       $('#newshow_daterange').addClass("btn-success")
       $('#newshow_daterange').html(start.fromNow() + ' - ' + end.fromNow());
       $('#newshow_start_time').text(start.toISOString())
       $('#newshow_end_time').text(end.toISOString())
);

$("#newshow_submit").click () ->
  venue_collection = new VenueCollection()
  artists_collection = new ArtistCollection()
  artists_ids = []
  for artist in $("#artists_selected > span")
    artists_ids.push $(artist).attr('data-id')
  $.when(
    artists_collection.fetch({
      data:
        'id__in': artists_ids.join(',')
    }),
    venue_collection.fetch({
      data:
        'id': parseInt($("#venue_selected").attr("data-id"))
    })
  ).done () ->
    artists = []
    for artist in artists_collection
      artists.push artist.attributes
    new_concert = new ConcertModel(
      {
        venue: venue_collection.models[0].attributes
        artists: artists
      }
    )


  start_time = $("#newshow_start_time").text()
  end_time = $("#newshow_end_time").text()
