api_url = "http://showshows.net"

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
    return api_url + "/api/v1/concert/"
  model: ConcertModel

concerts = new ConcertCollection()
venues = new VenueCollection()

pull_concerts = (options) ->
  while (model = venues.first())
    venues.remove(model)
  map.removeMarkers()

  concerts.fetch({
    data: options,
    success: () ->
      venues.each (venue) ->
        venue.updateInfoWindow()
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
  pull_concerts({})


$(document).ready () ->
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
  );

