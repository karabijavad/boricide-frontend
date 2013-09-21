api_url = "http://showshows.net"

class VenueModel extends Backbone.Model
  marker: {},
  concerts: [],
  initialize: () ->
    @marker = window.map.addMarker({
        lat: @attributes.lat,
        lng: @attributes.lng,
        infoWindow: {}
    })
  updateInfoWindow: () ->
    iw = @marker.infoWindow
    current_content = iw.getContent()
    if current_content
      new_content = current_content
    else
      new_content = ""
    for concert in @concerts
      this_concert = concert.attributes
      start_time = moment(this_concert.start_time).fromNow()
      end_time = moment(this_concert.end_time).fromNow()
      new_content += \
      "beggining #{start_time} <br/>
      ending #{end_time} <br/>
      #{this_concert.name} <br/>
      $#{this_concert.door_price}"
      new_content += "<ul style='list-style-type:none'>"
      for artist in this_concert.artists
        new_content += \
        "<li><i>#{artist.name}</i></li>"
      new_content += "</ul>"
      new_content += "<hr>"
    iw.setContent(new_content)

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
