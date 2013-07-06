Backbone.Tastypie.apiKey.username = "guest";
Backbone.Tastypie.apiKey.key = "6b0ed8aef817c6002850b6fa301915c2485ee8eb";

var api_url = "http://boricide";

var VenueModel = Backbone.Model.extend({
});

var VenueCollection = Backbone.Collection.extend({
  model: VenueModel
});


var ConcertModel = Backbone.Model.extend({
  venue: undefined,
  initialize: function () {
    this.venue = venues.findWhere(this.attributes.venue);
    if (!this.venue) {
      this.venue = new VenueModel(this.attributes.venue);
      venues.add(this.venue);
    }
  }
});

var ConcertCollection = Backbone.Collection.extend({
  url: function () {
    return api_url + "/api/v1/concert/";
  },
  model: ConcertModel
});

var concerts = new ConcertCollection();
var venues = new VenueCollection();

$(document).ready(function() {
  concerts.fetch();
});
