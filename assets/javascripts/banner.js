/* Code for Banner UI */
Event.observe(window, "load", switchTimerField, false);

function switchTimerField(){
	Event.observe("settings_use_timer", "click", changeView, false);
}

function changeView(evt){
    var vis = (settings_use_timer.checked) ? "block" : "none"; 
    banner_timer_setting.style.display = vis;
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
}
