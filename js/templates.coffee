Handlebars.registerHelper('fromNow', (context, block) ->
    return moment(context).fromNow()
)

concert_template = Handlebars.compile("
{{#each concerts}}
  {{fromNow attributes.start_time}}<br/>
  {{attributes.description}}
{{/each}}
")
