($ '#search').on 'keyup', (event) ->
    val = ($ this).val()
    setTimeout (() ->
        if ($ '#search').val() == val
            ($ '#search').trigger 'search'), 200

($ '#search').on 'search', (event) ->
    $.get "https://gdata.youtube.com/feeds/api/videos?v=2&q=#{($ this).val()}", (data,status,xhr) ->
        results = ($ '<div></div>')
        ($ data).find('entry').each (index,elem) ->
            parse = (query) -> ($ elem).find(query).first().text()
            result = ($ '#preload > .result').clone()
            (result.find 'img').attr 'src', ($ elem).find('thumbnail').first().attr 'url'
            (result.find 'h1').text parse 'title'
            (result.find '.author').text parse 'author > name'
            (result.find '.date').text parse 'published'
            (result.find 'p').text parse 'description'
            (result.find '.video').text ($ elem).find('content').first().attr 'src'
            (result.find 'a').attr 'href', ($ elem).find('link[rel=alternate]').first().attr 'href'
            results.append result
        ($ '#results').empty().append results

($ '#results').on 'click', '.result', (event) ->
    video = ($ this).find('.video').first()
    if video.find('iframe').length == 0
        href = video.text()
        video.empty().append "<iframe allowfullscreen src=\"#{href}\" />"
    ($ this).toggleClass 'open'

($ '#search').val('skateboarding dog')
($ '#search').trigger 'search'
($ '#search').focus()
