$ ->
  $('select#per').change ->
    $('#collaborators_form').submit() if $('#collaborators_form').length > 0
    $('#topics_form').submit() if $('#topics_form').length > 0

  $('input[type=submit]').change ->
    $('#collaborators_form').submit() if $('#collaborators_form').length > 0
    $('#topics_form').submit() if $('#topics_form').length > 0
