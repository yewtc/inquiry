function checking (q, i, u) {
    $('input[name*="' + q + '-"]')
        .not('input[name*="-' + i + '"]')
        .removeAttr("checked");
    div = $('div[name="fold' + q + '"]');
    if (u && $(div).attr('hidden')) {
        $(div).removeAttr('hidden');
        $(div).find('input').first().attr('checked', 'checked');
    } else {
        $(div).attr('hidden', 'hidden');
        $(div).find('input').removeAttr('checked');
    }
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