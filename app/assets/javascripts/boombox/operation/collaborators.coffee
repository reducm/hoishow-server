$ ->
  $('select#per').change ->
    $('#collaborators_form').submit()

  $('input[type=submit]').change ->
    $('#collaborators_form').submit()
