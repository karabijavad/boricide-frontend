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
{{#each concerts}}
<div class='concert-info'>
  <span class='time'>{{momentCalendar attributes.start_time}}</span>&nbsp;-&nbsp;
  <span class='artists-list'>
  {{#foreach attributes.artists}}
    {{#if website}}<a href='{{website}}'>{{/if}}
      <span class='artist-name'>{{name}}{{#unless $last}}, {{/unless}}
    {{#if website}}</a>{{/if}}
      </span>
  {{/foreach}}
  ${{attributes.door_price}}
  </span>
</div>
{{/each}}
")
