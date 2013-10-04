api_url = "http://showshows.net"
Backbone.Tastypie.apiKey["username"] = "guest"
Backbone.Tastypie.apiKey["key"] = "d9f3100bb2563e9511032bdec01c6d42f8691013"

class VenueModel extends Backbone.Model
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
  model: VenueModel

class ConcertModel extends Backbone.Model
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

pull_concerts = (options) ->
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
  pull_concerts({})

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

  $('#artist_name').typeahead({
    source: (query, process) ->
        return $.get "#{api_url}/api/v1/artist/", { "name__icontains": query }, (data) ->
          options = []
          for artist in data.objects
            options.push(artist["name"])
          return process(options);
  })

  $("#filters_submit").click () ->
    options = {}
    if $('#start_time').text()
      options["start_time__gte"] = $('#start_time').text()
    if $('#end_time').text()
      options["start_time__lte"] = $('#end_time').text()
    if $('#max_cost').val()
      options["door_price__lte"] = $('#max_cost').val()
      options["advance_price__lte"] = $('#max_cost').val()
    if $('#artist_name').val()
      options["artists__name__icontains"] = $('#artist_name').val()

    pull_concerts(options)