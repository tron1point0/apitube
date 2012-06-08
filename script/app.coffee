($ '#search').on 'keyup', (event) ->
    $t = $ this
    val = $t.val()
    setTimeout (-> if $t.val() == val
        $t.trigger 'search'), 200

($ '#search').on 'search', -> $.get (youtube ($ this).val(),1), (data) ->
    window.location.hash = encodeURI ($ '#search').val()
    ($ document).scrollTop(0)
    ($ '#results').empty().trigger 'load', data

mapping = (fn,from,to) -> (obj) -> (from ff)[fn] (to tf)[fn]() for ff,tf of obj
youtube = (youtube,offset) ->
    "https://gdata.youtube.com/feeds/api/videos?v=2&max-results=10&start-index=#{offset}&q=#{youtube}"

($ '#results').on 'load', (e,data) ->
    $t = $ this
    ($ data).find('entry').each ->
        d = $ this
        r = ($ '#preload > .result').clone()
        $d = (query) -> d.find(query)
        $r = (query) -> r.find(query)
        video = ($d 'content:first').attr 'src'
        (mapping 'text', $r, $d) {
            h1: 'title:first'
            '.author': 'author > name'
            '.date': 'published'
            p: 'description' }
        ($r 'img').attr 'src', ($d 'thumbnail:first').attr 'url'
        ($r 'a').attr 'href', ($d 'link[rel=alternate]').attr 'href'
        r.on 'click.loadVideo', ->
            ($ this)
                .off('click.loadVideo')
                .find('iframe').attr 'src', video
        $t.append r

loadMore = (event) ->
    $t = $ this
    $t.off 'more'
    $.get (youtube $t.val(), ($ '.result').length), (data) ->
        ($ '#results').trigger 'load', data
        $t.on 'more', loadMore
($ '#search').on 'more', loadMore

($ document).on 'scroll', ->
    results = ($ '.result')
    elem = results.last().prev()
    offset = elem.offset().top - ($ window).height()
    if results.length > 0 and ($ this).scrollTop() > offset
        ($ '#search').trigger 'more'

($ 'body').on 'click', '#results > .result', (event) ->
    ($ '.open').not($ this).removeClass 'open'
    ($ this).toggleClass 'open'

($ '#search').val decodeURI window.location.hash.replace /^#/,''
($ '#search').trigger 'search'
($ '#search').focus()
