# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
jQuery ->
    $('#gametable').DataTable({
        "searching": false,
        "autoWidth": true,
        "lengthChange": false,
        "pageLength": 20,
        "columnDefs": [
            { "orderable": false, "targets": [0,6] }
        ],
        "order": [ 1, 'asc' ]
    });