/* Code for Banner UI */
function checkDateRange(event, confirm_msg, date_range_error_msg){
  var s = $F('settings_start_ymd') + " " + $F('settings_start_hour') + ":" + $F('settings_start_min');
  var e = $F('settings_end_ymd') + " " + $F('settings_end_hour') + ":" + $F('settings_end_min');
  if (e.replace(/\-\s:/gi,"") < s.replace(/\-\s:/gi,"")) {
    window.alert(date_range_error_msg + " (From " + s + " to " + e + ")");
    event.stop();
    return false;
  }
  var response = confirm(confirm_msg); 
  if(!response){
    event.stop();
    return false;
  }
  return true;
}

function changeView(evt){
    var vis = evt.checked ? "block" : "none"; 
    $("#banner_timer_setting").toggle();
}

function checkDateValue(event, confirm_msg, error_msg) {
    var start_ymd = $("settings_start_ymd").value;
    var start_hour = $("settings_start_hour").value;
    var start_min = $("settings_start_min").value;

    var end_ymd = $("settings_end_ymd").value;
    var end_hour = $("settings_end_hour").value;
    var end_min = $("settings_end_min").value;

    var s_time = start_ymd.replace("-","") + start_hour + start_min;
    var e_time = end_ymd.replace("-","") + end_hour + end_min;

    if (e_time < s_time) {
      window.alert(error_msg);
      event.stop();
      return false;
    }
    var response = confirm(confirm_msg); 
    if(!response){
      event.stop();
    }
    return true;
}
