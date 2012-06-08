($ '#search').on 'keyup', (event) ->
    val = ($ this).val()
    setTimeout (() ->
        if ($ '#search').val() == val
            ($ '#search').trigger 'search'), 200

mapping = (fn,from,to) -> (obj) -> (from ff)[fn] (to tf)[fn]() for ff,tf of obj
youtube = (youtube,offset) ->
    "https://gdata.youtube.com/feeds/api/videos?v=2&max-results=10&start-index=#{offset}&q=#{youtube}"

search = (query,offset,fn) -> $.get (youtube query,offset), (data) ->
    fn.call ($ data).find('entry').map ->
        data = this
        result = ($ '#preload > .result').clone()
        $d = (query) -> ($ data).find(query).first()
        $r = (query) -> ($ result).find(query).first()
        video = ($d 'content').attr 'src'
        (mapping 'text', $r, $d) {
            h1: 'title'
            '.author': 'author > name'
            '.date': 'published'
            p: 'description' }
        ($r 'img').attr 'src', ($d 'thumbnail').attr 'url'
        ($r 'a').attr 'href', ($d 'link[rel=alternate]').attr 'href'
        result.on 'click.loadVideo', (event) ->
            ($ this)
                .off('click.loadVideo')
                .find('iframe').attr 'src', video
        result

($ '#search').on 'search', (event) -> search ($ this).val(), 1, ->
    ($ '#results').empty()
    this.each -> ($ this).appendTo '#results'

loader = (event) ->
    ($ this).off 'load'
    search ($ this).val(), ($ '.result').length, ->
        this.each -> ($ this).appendTo '#results'
        ($ '#search').on 'load', loader
($ '#search').on 'load', loader

($ document).on 'scroll', ->
    results = ($ '.result')
    elem = results.last().prev()
    offset = elem.offset().top - ($ window).height()
    console.log ($ this).scrollTop(), offset
    if results.length > 0 and ($ this).scrollTop() > offset
        ($ '#search').trigger 'load'

($ 'body').on 'click', '#results > .result', (event) ->
    ($ this).toggleClass 'open'

($ '#search').val('skateboarding dog')
($ '#search').trigger 'search'
($ '#search').focus()
