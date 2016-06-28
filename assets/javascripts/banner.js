/* Code for Banner UI */
function checkDateRange(event, confirm_msg, date_range_error_msg) {
    var s = $('#settings_start_ymd').val() + " " + $('#settings_start_hour').val() + ":" + $('#settings_start_min').val();
    var e = $('#settings_end_ymd').val() + " " + $('#settings_end_hour').val() + ":" + $('#settings_end_min').val();
    if (e.replace(/\-\s:/gi, "") < s.replace(/\-\s:/gi, "")) {
        window.alert(date_range_error_msg + " (From " + s + " to " + e + ")");
        return false;
    } else {
        var response = confirm(confirm_msg);
        if (response) {
            return true;
        }
    }
    return false;
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

function displayTopBanner() {
    if (window.matchMedia( '(max-width: 899px)' ).matches) {
        $('#content').prepend($('.banner_area').first());
    } else {
        $('.banner_area').first().insertAfter($('#top-menu'));
    };
}
