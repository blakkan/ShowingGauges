

$(document).ready (
  function() {

    console.log("hi");

    $('#the_table_id').on('click-row.bs.table', function (e, row, element, field) {
      var sku = row['sku'];
      var loc = row['loc'];
      var qty = row['qty'];
      console.log(JSON.stringify(field));
      window.location.href = "http://localhost:3000/display_transfer_request_screen" +
        '/' + sku + '/' + loc + '/' + qty;
      return false;
    });


  }
);
