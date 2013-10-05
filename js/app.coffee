api_url = "http://showshows.net"
username = "guest"
apikey = "d9f3100bb2563e9511032bdec01c6d42f8691013"
Backbone.Tastypie.apiKey["username"] = username
Backbone.Tastypie.apiKey["key"] = apikey

`function getURLParameter(name) {
    return decodeURI(
        (RegExp(name + '=' + '(.+?)(&|$)').exec(location.search)||[,null])[1]
    );
}`

class ArtistModel extends Backbone.Model
  url: () ->
    return "#{api_url}#{@id}"

class ArtistCollection extends Backbone.Collection
  url: () ->
    return "#{api_url}/api/v1/artist/"
  model: ArtistModel

class VenueModel extends Backbone.Model
  url: () ->
    return "#{api_url}#{@id}"
  initialize: () ->
    @marker = window.map.addMarker({
        lat: @attributes.lat,
        lng: @attributes.lng,
        infoWindow: {}
    })
    @concerts = []
  updateInfoWindow: () ->
    @marker.infoWindow.setContent concert_template({concerts: @concerts})

class VenueCollection extends Backbone.Collection
  url: () ->
    return "#{api_url}/api/v1/venue/"
  model: VenueModel

class ConcertModel extends Backbone.Model
  url: () ->
    return "#{api_url}#{@id}"
  initialize: () ->
    @venue = venues.findWhere @attributes.venue
    if not @venue
      @venue = new VenueModel @attributes.venue
      venues.add @venue
    @venue.concerts.push this

class ConcertCollection extends Backbone.Collection
  url: () ->
    return "#{api_url}/api/v1/concert/"
  model: ConcertModel

concerts = new ConcertCollection()
venues = new VenueCollection()
artists = new ArtistCollection()

pull_concerts = () ->
  options = {}
  if $('#start_time').text()
    options["start_time__gte"] = $('#start_time').text()
  if $('#end_time').text()
    options["start_time__lte"] = $('#end_time').text()
  if $('#max_cost').val()
    options["door_price__lte"] = $('#max_cost').val()
    options["advance_price__lte"] = $('#max_cost').val()
  if $('#filters_selected_artist').attr('data-id')
    options["artists__id"] = $('#filters_selected_artist').attr('data-id')

  $('body').modalmanager('loading')

  while (model = venues.first())
    venues.remove(model)
  map.removeMarkers()

  concerts.fetch({
    data: options,
    success: () ->
      venues.each (venue) ->
        venue.updateInfoWindow()
      $('.modal-scrollable').trigger('click')
  })

$(document).ready () ->
  window.map = new GMaps({
    div: '#map',
    lat: 41.920955,
    lng: -87.694332,
    zoom: 12
  })

  address = getURLParameter("address")
  console.log("address is")
  console.log(address)
  if address is not "null"
    GMaps.geocode({
      address: address,
      callback: (results, status) ->
        if status == 'OK'
          latlng = results[0].geometry.location;
          window.map.setCenter(latlng.lat(), latlng.lng());
    });

  if navigator.geolocation
    navigator.geolocation.getCurrentPosition (position) ->
      map.setCenter(position.coords.latitude, position.coords.longitude)
  map.addControl({
    position: 'right_top',
    content: 'Filters',
    style: {
      margin: '5px',
      padding: '1px 6px',
      border: 'solid 1px #717B87',
      background: '#fff'
    },
    events: {
      click: () ->
        if $("#map").width() == $(window).width()
          $("#map").animate({"width": "75%"}, 150 )
          $("#sidebar").show().animate({"width": "25%"}, 150 )
        else
          $("#map").animate({"width": "100%"}, 150 )
          $("#sidebar").hide().animate({"width": "0%"}, 150 )
    }
  })
  map.addControl({
    position: 'top_left',
    content: 'Add a show',
    style: {
      margin: '5px',
      padding: '1px 6px',
      border: 'solid 1px #717B87',
      background: '#fff'
    },
    events: {
      click: () ->
        $('body').modalmanager('loading')
        $modal = $('#ajax-modal')
        $modal.load '/add_show.html', '', () ->
          $modal.modal()
    }
  })
  pull_concerts()

  $('#reportrange').daterangepicker(
      {
        timePicker: true,
        ranges: {
           'Today': [moment().startOf('day'), moment().endOf('day')],
           'This coming week': [moment().startOf('day'), moment().add('days', 7).endOf('day')],
        },
      },
      (start, end) ->
         $('#reportrange span').html(start.format('MMMM D, YYYY') + ' - ' + end.format('MMMM D, YYYY'));
         $('#start_time').text(start.toISOString())
         $('#end_time').text(end.toISOString())
  );

  artist_map = {}
  $("#artist_name").typeahead({
    source: (query, process) ->
      options = []
      $.get "#{api_url}/api/v1/artist/", {"name__icontains": query, "username": username, "api_key": apikey}, (data) ->
        for artist in data.objects
          artist_map[artist["name"]] = artist["id"]
          options.push(artist["name"])
        return process(options)
    updater: (artist_name) ->
      artist_id = artist_map[artist_name]
      $("#artist_name").hide()
      $("#filters_selected_artist")
        .text(artist_name)
        .attr('data-id',artist_id)
        .click () ->
          $("#filters_selected_artist").text('').attr('data-id','').hide()
          $("#artist_name").val('').show()
        .show()
      return ''
  })

  $("#filters_submit").click () ->
    pull_concerts()