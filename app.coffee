Ext.Loader.setConfig {enabled: true}
Ext.Loader.setPath 'Ext.ux', 'extjs-4.1.0/examples/ux'
Ext.require ['Ext.data.*','Ext.grid.*','Ext.ux.RowExpander','Ext.ux.PreviewPlugin','Ext.container.*']

defaultSearch = 'skateboarding dog'
searchUrl = -> "http://gdata.youtube.com/feeds/api/videos?v=2&alt=rss&q=#{this}"
watchUrl = -> "http://www.youtube.com/v/#{this}?version=3"
thumbUrl = -> "http://i.ytimg.com/vi/#{this}/default.jpg"

tc = (string) -> string[0].toUpperCase() + (string.substr 1)
withIndex = (index) -> (obj) ->
    obj.text = tc index
    obj.dataIndex = index
    obj

named = (name) -> {name: name}
convert = (id,fn) -> (obj) ->
    obj.convert = (data,record) -> fn.call record.get(id), record.get(id)
    obj
match = (regex) -> -> (this.match regex)[1]
lift1 = (fn,args...) -> -> fn this, args...
Ext.define 'Video', {
    extend: 'Ext.data.Model'
    fields: ['guid','title','link','author','pubDate','description',
        (convert 'description', lift1 Ext.util.Format.ellipsis, 240, true)(named 'shortdesc'),
        (convert 'pubDate', Ext.util.Format.date)(named 'date'),
        (convert 'guid', match /:([^:]+)$/)(named 'vid'),
        (convert 'vid', watchUrl)(named 'embed'),
        (convert 'vid', thumbUrl)(named 'thumbnail')]}

Ext.onReady ->
    store = new Ext.data.Store {
        autoLoad: true
        model: 'Video'
        proxy: {
            type: 'ajax'
            url: (searchUrl.call defaultSearch)
            reader: {
                type: 'xml'
                record: 'item'
                root: 'channel'}}}

    search = new Ext.form.field.Text {
        name: 'query'
        value: defaultSearch
        fieldLabel: 'Search'
        enableKeyEvents: true}

    grid = new Ext.grid.Panel {
        store: store
        plugins: [{
            ptype: 'rowexpander',
            selectRowOnExpand: true,
            rowBodyTpl: ['<span class="iframe">{embed}</span><p class="description">{description}</p>']}]
        tbar: (new Ext.toolbar.Toolbar {items: [search]})
        columns: [
            (withIndex 'title')({
                flex: 5
                renderer: (value,p,record) ->
                    "<img class=\"thumbnail\" src=\"#{record.data.thumbnail}\" />" +
                    "<h1 class=\"title\">#{value}</h1>" +
                    "<p class=\"shortdesc\">#{record.data.shortdesc}</p>" +
                    "<a class=\"permalink\" href=\"#{record.data.link}\">Watch on YouTube</a>"}),
            (withIndex 'author')({flex: 1}),
            (withIndex 'date')({flex: 1})]}

    # Only load the iframe when the user expands the row
    grid.view.on 'expandbody', (fullRow, record, row) ->
        span = row.querySelector 'span.iframe'
        if span
            video = span.innerHTML
            span.outerHTML =
                "<iframe class=\"video\" type=\"text/html\" allowfullscreen src=\"#{video}\" />" +
                "<p class=\"description\">#{record.data.description}</p>"

    # Search while typing
    search.on 'keyup', ->
        store.getProxy().url = searchUrl.call this.value
        store.load()

    # Full-page view
    new Ext.Viewport {
        layout: 'fit'
        items: [grid]}
