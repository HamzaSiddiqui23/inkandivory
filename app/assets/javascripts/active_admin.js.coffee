#= require active_admin/base
#= require active_material
#= require chartkick

  $(document).ready ->
    $ ->
      $('#in_revision_button').click (event) ->
        ActiveAdmin.modal_dialog 'Revision Due Date: ', {  dueDate: 'datepicker' }, (inputs) ->
          window.location = location.pathname+"/move_to_revision"+"?due_date="+encodeURIComponent(inputs.dueDate)
          return
        event.preventDefault()
    $ ->
      $('#bonus_button').click (event) ->
        ActiveAdmin.modal_dialog 'Bonus: ', {  amount: 'number' }, (inputs) ->
          window.location = location.pathname+"/add_bonus"+"?bonus="+encodeURIComponent(inputs.amount)
          return
        event.preventDefault()
    $ ->
      $('#advance_button').click (event) ->
        ActiveAdmin.modal_dialog 'Advance: ', {  amount: 'number' }, (inputs) ->
          window.location = location.pathname+"/add_advance"+"?advance="+encodeURIComponent(inputs.amount)
          return
        event.preventDefault()

  window.printElem = (elem) ->
    mywindow = window.open('', 'PRINT')
    mywindow.document.write '<html><head><title>' + document.title + '</title>'
    mywindow.document.write '<style type="text/css">' + 'table th, table td {' + 'border:1px solid #000;' + 'padding:0.5em;' + 'text-align:center;'  + '}' + 'span > a { display: none;} ' + '</style>'
    mywindow.document.write '</head><body >'
    mywindow.document.write document.getElementById(elem).innerHTML
    mywindow.document.write '</body></html>'
    mywindow.document.close()
    # necessary for IE >= 10
    mywindow.focus()
    # necessary for IE >= 10*/
    mywindow.print()
    mywindow.close()
    true
