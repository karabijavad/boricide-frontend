venue_map = {}

$("#venue_text").typeahead({
  source: (query, process) ->
    options = []
    $.get "#{api_url}/api/v1/venue/",
      "name__icontains": query
      "username": username
      "api_key": apikey
      (data) ->
        unless data.objects.length then return process(["#{query}"])
        for venue in data.objects
          venue_map[venue["name"]] = venue["id"]
          options.push(venue["name"])
        return process(options)
  updater: (venue_name) ->
    venue_id = venue_map[venue_name]
    if not venue_id
      venues.create {name:  venue_name.match(/[^,]*/)[0], address: $.trim venue_name.match(/,(.*)/)[1] },
        success: (data) ->
          console.log(data)
          $("#venue_text").hide()
          $("#venue_selected")
            .text(data.attributes.name)
            .attr("data-id", data.attributes.id)
            .click () ->
              $("#venue_selected").text('').attr("data-id", '').hide()
              $("#venue_text").val(data.attributes.name).show().focus()
            .show()
      return ''
    $("#venue_text").hide()
    $("#venue_selected")
      .text(venue_name)
      .attr("data-id", venue_id)
      .click () ->
        $("#venue_selected").text('').attr("data-id", '').hide()
        $("#venue_text").val(venue_name).show().focus()
      .show()
})

artist_map = {}

$("#artist_text").typeahead({
  source: (query, process) ->
    options = []
    $.get "#{api_url}/api/v1/artist/",
      "name__icontains": query
      "username": username
      "api_key": apikey,
      (data) ->
        unless data.objects.length then return process([query])
        for artist in data.objects
          artist_map[artist["name"]] = artist["id"]
          options.push(artist["name"])
        return process(options)
  updater: (artist_name) ->
    artist_id = artist_map[artist_name]
    unless artist_id
      artists.create {name: artist_name}
        success: (data) ->
          $("<span class='btn btn-success btn-lg' data-id='#{data.attributes.id}'>#{data.attributes.name}</span>")
            .appendTo("#artists_selected")
            .click () ->
              $(this).remove()
      return ''
    if not $("#artists_selected > [data-id=#{artist_id}]").length
      $("<span class='btn btn-success btn-lg' data-id='#{artist_id}'>#{artist_name}</span>")
        .appendTo("#artists_selected")
        .click () -> $(this).remove()
    return ''
})

$('#newshow_daterange').daterangepicker(
    {
      timePicker: true,
      startDate: moment().hour(20)
      endDate: moment().add('days', 1).hour(2)
    },
    (start, end) ->
       $('#newshow_daterange').removeClass('btn-default').addClass("btn-success")
       $('#newshow_daterange').html(start.fromNow() + ' - ' + end.fromNow());
);

$("#newshow_submit").click () ->
  $("#newshow_loading").css("visibility", "visible")
  venue_collection = new VenueCollection()
  venue_collection.url = "#{api_url}/api/v1/venue/"
  artists_collection = new ArtistCollection()
  artists_collection.url = "#{api_url}/api/v1/artist/"
  artists_ids = []
  for artist in $("#artists_selected > span")
    artists_ids.push $(artist).attr('data-id')
  $.when(
    artists_collection.fetch
      url: "#{artists_collection.url}?id__in=#{artists_ids.join(',')}",
    venue_collection.fetch
      data:
        'id': parseInt($("#venue_selected").attr("data-id"))
   ).done () ->
      artists = []
      artists_collection.each (artist) ->
        artists.push artist.attributes
      concerts.create {
          name: $("#newshow_title_accepted").text()
          description: $("#newshow_description").val()
          start_time: $("#newshow_daterange").data("daterangepicker").startDate.toISOString()
          end_time: $("#newshow_daterange").data("daterangepicker").endDate.toISOString()
          venue: venue_collection.models[0].attributes
          artists: artists
          door_price: $("#newshow_doorprice_accepted").attr('data-doorprice')
      }, {
        success: (data) ->
          $("#newshow_loading").css("visibility", "hidden")
          pull_concerts()
      }

$("#newshow_title").focusout () ->
  if $("#newshow_title").val()
    $("#newshow_title").hide()
    $("#newshow_title_accepted").text($("#newshow_title").val()).show().click () ->
      $("#newshow_title_accepted").hide()
      $("#newshow_title").show().focus()

$("#newshow_doorprice").focusout () ->
  if $("#newshow_doorprice").val()
    $("#newshow_doorprice").hide()
    $("#newshow_doorprice_accepted")
      .text('$' + $("#newshow_doorprice").val())
      .attr('data-doorprice', $("#newshow_doorprice").val())
      .show()
      .click () ->
        $("#newshow_doorprice_accepted").hide()
        $("#newshow_doorprice").show().focus()