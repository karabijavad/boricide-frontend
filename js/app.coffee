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

$(document).ready () ->
  window.map = new GMaps({
    div: '#map',
    lat: 41.920955,
    lng: -87.694332,
    zoom: 12
  })
  concerts.fetch({
    success: () ->
      venues.each (venue) ->
        venue.updateInfoWindow()
  })
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
        $modal = $('#ajax-modal');
        $('body').modalmanager('loading');
        $modal.load('/filters.html', '', () ->
          $modal.modal()
        )
        $modal.on('click', '.update', () ->
          $modal.find('.modal-body').prepend('<div class="alert alert-info fade in">' + 'Updated!<button type="button" class="close" data-dismiss="alert">&times;</button>' + '</div>')
        )
        $modal.on('click', '.btn-primary', () ->
          $modal.close()
        )
    }
  })

