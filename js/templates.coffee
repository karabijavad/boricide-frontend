Handlebars.registerHelper('momentCalendar', (context, block) ->
    return moment(context).calendar()
)

concert_template = Handlebars.compile("
{{#each concerts}}
<div class='concert-info'>
  <span class='time'>Starting {{momentCalendar attributes.start_time}}</span>
  <br/>
    <ul class='artists-list'>
    {{#each attributes.artists}}
      <li>{{name}}</li>
    {{/each}}
    </ul>
  <span class='concert-description'>{{attributes.description}}</span>
</div>
{{/each}}
")
