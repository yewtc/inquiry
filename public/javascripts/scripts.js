function checking (q, i, u) {
    $('input[name*="' + q + '-"]')
        .not('input[name*="-' + i + '"]')
        .removeAttr("checked");

        var qn = q;
        if (qn.substr(0,1) == 'a') {
            qn = qn.substr(1);
        }

    if (u) {
        var div = $('div[name*="' + qn + '-' + i + '"]');
        if ($(div).attr('disabled')) {
            $(div).show();
            $(div).removeAttr('disabled');
            $(div).find('input').removeAttr('disabled');
            $(div).find('input').first().attr('checked', 'checked');
        } else {
            $(div).hide();
            $(div).attr('disabled', 'disabled');
            $(div).find('input').attr('disabled', 'disabled');
            $(div).find('input').removeAttr('checked');
        }
    }

    var others = $('div[name*="' + q + '-"]').not('[name*="-' + i + '"]');
    others.hide();
    others.attr('disabled', 'disabled');
    others.find('input').removeAttr('checked');
}


function validate (msg, shownum) {
    var ps = $('div[name^="p"]');
    for (i=0; i< ps.length ; i++ ) {
        var p = ps[i];
        var checked = $(p).find('input:checked');
        if (checked.length == 0) {
            alert(msg + (shownum ? ' ' + (i + 1) : '.' ));
            return false;
        }
    }
    return true;
}

window.history.forward();
function noBack() { window.history.forward(); }
