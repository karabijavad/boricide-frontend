api_url = "http://23.253.41.107:81"
username = "guest"
apikey = "c43c0a99b60c2d093ee2d2242449d2a6a2021c32"
Backbone.Tastypie.apiKey["username"] = username
Backbone.Tastypie.apiKey["key"] = apikey

`function getURLParameter(name) {
    return decodeURIComponent(
      (RegExp('[?|&]' + name + '=' + '(.+?)(&|$)').exec(location.search)||[,""])[1]
    );
}
`

class ArtistModel extends Backbone.Model

class ArtistCollection extends Backbone.Collection
  model: ArtistModel

class VenueModel extends Backbone.Model
  initialize: () ->
    @marker = {}
    @concerts = []
  place: () ->
    @marker = window.map.addMarker
        lat: @attributes.lat,
        lng: @attributes.lng,
        infoWindow: {}
  updateInfoWindow: () ->
    @concerts.sort (a, b) -> return (a.attributes.start_time > b.attributes.start_time)
    @marker.infoWindow.setContent concert_template
      concerts: @concerts
      venue: this

class VenueCollection extends Backbone.Collection
  model: VenueModel

class ConcertModel extends Backbone.Model
  initialize: () ->
    @venue = venues.findWhere @attributes.venue
    if not @venue
      @venue = new VenueModel @attributes.venue
      @venue.place()
      venues.add @venue
    @venue.concerts.push this

class ConcertCollection extends Backbone.Collection
  model: ConcertModel

concerts = new ConcertCollection
concerts.url = "#{api_url}/api/v1/concert/"
venues = new VenueCollection
venues.url = "#{api_url}/api/v1/venue/"
artists = new ArtistCollection
artists.url = "#{api_url}/api/v1/artist/"

pull_concerts = () ->
  options =
    'limit': 0
    'venue__lat__lte': window.map.getBounds().getNorthEast().lat()
    'venue__lat__gte': window.map.getBounds().getSouthWest().lat()
    'venue__lng__lte': window.map.getBounds().getNorthEast().lng()
    'venue__lng__gte': window.map.getBounds().getSouthWest().lng()

  $drp = $('#reportrange').data("daterangepicker")
  if $drp
    options["start_time__range"] = "#{$drp.startDate.toISOString()},#{$drp.endDate.toISOString()}"
  if $('#max_cost').val()
    options["door_price__lte"] = $('#max_cost').val()
    options["advance_price__lte"] = $('#max_cost').val()
  if $('#filters_selected_artist').attr('data-id')
    options["artists__id"] = $('#filters_selected_artist').attr('data-id')

  $('body').modalmanager('loading')

  while (model = venues.first())
    venues.remove(model)
  map.removeMarkers()
  while (model = concerts.first())
    concerts.remove(model)

  console.log("fetching concerts")
  concerts.fetch
    data: options
    error: (data, a) ->
      console.log("error")
      console.log(data)
      console.log(a)
      $('.modal-scrollable').trigger('click')
    success: () ->
      venues.each (venue) ->
        venue.place()
        venue.updateInfoWindow()
      $('.modal-scrollable').trigger('click')

$(document).ready () ->
  window.map = new GMaps
    div: '#map',
    lat: 41.920955,
    lng: -87.694332,
    zoom: 12

  google.maps.event.addListenerOnce window.map.map, 'idle', () ->
    pull_concerts()

  address = getURLParameter("address")
  if address
    GMaps.geocode
      address: address,
      callback: (results, status) ->
        if status == 'OK'
          latlng = results[0].geometry.location;
          window.map.setCenter(latlng.lat(), latlng.lng());
  else if navigator.geolocation
    navigator.geolocation.getCurrentPosition (position) ->
      map.setCenter(position.coords.latitude, position.coords.longitude)

  map.addControl
    position: 'right_top',
    content: 'Filters',
    style:
      margin: '5px',
      padding: '1px 6px',
      border: 'solid 1px #717B87',
      background: '#fff'
    events:
      click: () ->
        if $("#map").width() == $(window).width()
          $("#map").animate({"width": "75%"}, 150 )
          $("#sidebar").show().animate({"width": "25%"}, 150 )
        else
          $("#map").animate({"width": "100%"}, 150 )
          $("#sidebar").hide().animate({"width": "0%"}, 150 )
  map.addControl
    position: 'top_left',
    content: 'Add a show',
    style:
      margin: '5px',
      padding: '1px 6px',
      border: 'solid 1px #717B87',
      background: '#fff'
    events:
      click: () ->
        $('body').modalmanager('loading')
        $modal = $('#ajax-modal')
        $modal.load '/add_show.html', '', () ->
          $modal.modal()

  $('#reportrange').daterangepicker
    timePicker: true
    startDate: moment().startOf('hour')
    endDate: moment().add('days', 8).hour(2).startOf('hour')
    ranges:
       'Today': [moment().startOf('day'), moment().add('day', 1).hour(2).startOf('hour')]
       'This coming week': [moment(), moment().add('days', 8).hour(2).startOf('hour')],
    (start, end) ->
       $('#reportrange span').html "#{start.fromNow()} - #{end.fromNow()}"

  artist_map = {}
  $("#artist_name").typeahead
    source: (query, process) ->
      options = []
      $.get "#{api_url}/api/v1/artist/",
        "name__icontains": query
        "username": username
        "api_key": apikey,
        (data) ->
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

  $("#filters_submit").click () ->
    pull_concerts()
