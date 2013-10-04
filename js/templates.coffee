Handlebars.registerHelper('momentCalendar', (context, block) ->
    return moment(context).calendar()
)

Handlebars.registerHelper("foreach", (arr,options) ->
    if(options.inverse && !arr.length)
        return options.inverse(this)

    return arr.map((item,index) ->
        item.$index = index
        item.$first = index is 0
        item.$last  = index is arr.length-1
        return options.fn(item)
    ).join('')
)

concert_template = Handlebars.compile("
<table class='concert-list table table-hover'>
  {{#each concerts}}
    <tr class='concert-info'>
      <td class='time'>{{momentCalendar attributes.start_time}}</td>
      <td class='artists-list'>
        {{#foreach attributes.artists}}
            <span class='artist btn' data-id='{{id}}'>{{name}}</span>
        {{/foreach}}
      </td>
      <td>${{attributes.door_price}}</td>
    </tr>
  {{/each}}
</table>
")

artist_info_template = Handlebars.compile("
<div class='page-header'>
  <h1>{{name}} <small>{{#if website}}<a href='{{website}}'>{{website}}</a><br/>{{/if}}</small></h1>
</div>
<br/>
{{#if description}}
  {{description}}<br/>
{{/if}}
")

add_show_template = Handlebars.compile("
<div class='page-header'>
  <h1>Add show</h1>
</div>
")

$(document).on 'click', '.concert-info .artists-list .artist', (e) ->
  $modal = $('#ajax-modal')
  $('body').modalmanager('loading')
  $.getJSON "#{api_url}/api/v1/artist/#{$(this).attr('data-id')}/?username=#{username}&api_key=#{apikey}", (artist_data) ->
    $modal.html(artist_info_template(artist_data))
    $modal.modal()
