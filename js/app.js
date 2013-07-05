    Backbone.Tastypie.apiKey.username="guest";
    Backbone.Tastypie.apiKey.key="6b0ed8aef817c6002850b6fa301915c2485ee8eb";

    var api_url = "http://boricide"

    var ConcertCollection = Backbone.Collection.extend({
        url: function() {
            return api_url + "/api/v1/concert/?format=json";
        },
    });

    var concerts = new ConcertCollection();
    concerts.fetch();
