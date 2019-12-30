/* Code for Banner UI */
function checkDateRange(event, confirm_msg, date_range_error_msg) {
    let s = $('#setting_start_ymd').val() + " " + $('#setting_start_hour').val() + ":" + $('#setting_start_min').val();
    let e = $('#setting_end_ymd').val() + " " + $('#setting_end_hour').val() + ":" + $('#setting_end_min').val();
    if (e.replace(/\-\s:/gi, "") < s.replace(/\-\s:/gi, "")) {
        window.alert(date_range_error_msg + " (From " + s + " to " + e + ")");
        return false;
    } else {
        let response = confirm(confirm_msg);
        if (response) {
            return true;
        }
    }
    return false;
}

function displayTopBanner() {
    if (window.matchMedia( '(max-width: 899px)' ).matches) {
        $('#content').prepend($('div.banner_area.global_banner').first());
    } else {
        $('div.banner_area.global_banner').first().insertAfter($('#top-menu'));
    }
}

function displayTopAndBottomBanner() {
    if (window.matchMedia( '(max-width: 899px)' ).matches) {
        $('#content').prepend($('div.banner_area.global_banner').clone());
    } else {
        $('div.banner_area.global_banner').clone().insertAfter($('#top-menu'));
    }
}