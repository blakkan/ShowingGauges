

$(document).ready (
  function() {

    console.log("hi");
    
    $('#the_table_id').on('click-row.bs.table', function (e, row, element, field) {
      console.log(JSON.stringify(row));
      console.log(JSON.stringify(field));
    });
  }
);
