function checking (q, i, u) {
    $('input[name*="' + q + '-"]')
        .not('input[name*="-' + i + '"]')
        .removeAttr("checked");
    div = $('div[name="fold' + q + '"]');
    if (u && $(div).attr('hidden')) {
        $(div).removeAttr('hidden');
    } else {
        $(div).attr('hidden', 'hidden');
    }
}