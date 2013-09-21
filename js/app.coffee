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
    console.log(current_content)
    if current_content
      new_content = current_content
    else
      new_content = ""
    for concert in @concerts
      this_concert = concert.attributes
      new_content += \
      "#{this_concert.name} <br/>
      #{this_concert.door_price}"

      new_content += "<ul>"
      for artist in this_concert.artists
        new_content += \
        "<li>#{artist.name}</li>"
      new_content += "</ul>"
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
    });
    concerts.fetch({
      success: () ->
        venues.each((venue) ->
          venue.updateInfoWindow()
        )
    })
