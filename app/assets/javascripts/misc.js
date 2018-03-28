//
// These two functions are used in the bootstrap-table to
// sort fields other than as string sorts.
// first is to do an integer sort, second is to do
// a sort on currency.
//
var integer_sorter_jb = function(a,b) {
  return parseInt(a) - parseInt(b);
};

var dollar_sorter_jb = function(a,b) {
  return (Math.trunc(parseFloat(a.replace(/[^0-9\.-]/g,''))*100.)) - Math.trunc(parseFloat(b.replace(/[^0-9\.-]/g,''))*100.);
};

//
// Here we liven up the bootstrap-table of skus (not transaction!)
// by adding some links.
// Clicking on the SKU number takes you to the sku editing page
// Clicking on the qty takes you to the transfer page
// Click on the Location takes you to the location editing page.
//
// Note that the back-end is responsible for verifying that anyone
// taken to these pages has the authority (i.e. the admin capability)
// to edit the records.   Nothing is enforced here in javascript.
//

$(document).ready (
  function() {

    $('#the_table_id').on('click-row.bs.table', function (e, row, element, field) {

      // clicking on the quantity field takes us to the transfer screen
      if (field == 'qty') {
        var sku = row['sku_num'];
        var loc = row['loc'];
        var qty = row['qty'];


        window.location.href = "/display_transfer_request_screen" +
          '/' + sku + '/' + loc;
          return false; //cut off any further processing.  Sorry if you were
                        // planning anything, bootstrap or bootstrap-table...

      // clicking on the sku number field takes us to the sku edit screen
    } else if  ( field == 'sku_num' ) {


      window.location.href = "/display_manage_sku_request_screen" +
        '/' + row['sku_num'];
        return false; //cut off any further processing

    } else if  ( field == 'loc' ) {

      window.location.href = "/display_manage_location_request_screen" +
        '/' + row['loc'];
        return false; //cut off any further processing

      } else if  ( field == 'user' ) {

        window.location.href = "/display_manage_user_request_screen" +
          '/' + row['user'];
          return false; //cut off any further processing

      } else {
        return false;
      } //end of choice
    } // end of callback function
  ); // end of callback registration function

  //
  // This little runt function is just needed to give the
  // bootstrap date picker a little kick.
  // (We also repeat this, possibly redundantly) in some
  // of the html itself.

  $('.datetimepicker_class input').datepicker({format: 'yyyy-mm-dd'});

  }  // end of anonymous function

);
