concert_template = Handlebars.compile("
{{#each concerts}}
  {{attributes.description}}
{{/each}}
")
