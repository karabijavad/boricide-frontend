Backbone.Tastypie.apiKey.username = "guest";
Backbone.Tastypie.apiKey.key = "6b0ed8aef817c6002850b6fa301915c2485ee8eb";

var api_url = "http://boricide";

var VenueModel = Backbone.Model.extend({
});

var VenueCollection = Backbone.Collection.extend({
  model: VenueModel
});


var ConcertModel = Backbone.Model.extend({
});

var ConcertCollection = Backbone.Collection.extend({
  url: function () {
    return api_url + "/api/v1/concert/";
  },
  model: ConcertModel
});

var concerts = new ConcertCollection();
