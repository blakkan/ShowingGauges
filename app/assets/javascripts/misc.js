

$(document).ready (
  function() {

    $('#the_table_id').on('click-row.bs.table', function (e, row, element, field) {
      var sku = row['sku'];
      var loc = row['loc'];
      var qty = row['qty'];

      window.location.href = "/display_transfer_request_screen" +
        '/' + sku + '/' + loc + '/' + qty;
      return false;
    });

    $(function () {
      $('.datetimepicker_class input').datepicker();
      });

  }
);
