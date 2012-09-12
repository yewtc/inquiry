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
        if ($(div).attr('hidden')) {
            $(div).removeAttr('hidden');
            $(div).find('input').first().attr('checked', 'checked');
        } else {
            $(div).attr('hidden', 'hidden');
            $(div).find('input').removeAttr('checked');
        }
    }

    var others = $('div[name*="a' + qn + '-"]').not('[name*="-' + i + '"]');
    others.attr('hidden', 'hidden');
    others.find('input').removeAttr('checked');
}


function validate () {
    var ps = $('div[name^="p"]');
    for (i=0; i< ps.length ; i++ ) {
        var p = ps[i];
        var checked = $(p).find('input:checked');
        if (checked.length == 0) {
            alert('Chybi odpoved ' + (i + 1));
            return false;
        }
    }
    return true;
}

window.history.forward();
function noBack() { window.history.forward(); }
