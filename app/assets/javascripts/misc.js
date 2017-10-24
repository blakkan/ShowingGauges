var integer_sorter_jb = function(a,b){
  return parseInt(a) - parseInt(b)
};

var dollar_sorter_jb = function(a,b){
  return (Math.trunc(parseFloat(a.replace(/[^0-9\.-]/g,''))*100.)) - Math.trunc(parseFloat(b.replace(/[^0-9\.-]/g,''))*100.)
};

$(document).ready (
  function() {

    $('#the_table_id').on('click-row.bs.table', function (e, row, element, field) {

      if (field == 'qty') {
        var sku = row['sku_num'];
        var loc = row['loc'];
        var qty = row['qty'];

        window.location.href = "/display_transfer_request_screen" +
          '/' + sku + '/' + loc + '/' + qty;
          return false;

      } else if  ( field == 'sku_num' )

      window.location.href = "/display_manage_sku_request_screen" +
        '/' + row['sku_num'];
        return false;


      });





  }
);

$(function () {
  $('.datetimepicker_class input').datepicker();
  });
