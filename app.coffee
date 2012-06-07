Ext.Loader.setConfig {
    enabled: true,
}
Ext.Loader.setPath 'Ext.ux', 'extjs-4.1.0/examples/ux'
Ext.require ['Ext.data.*','Ext.grid.*','Ext.ux.RowExpander','Ext.ux.PreviewPlugin','Ext.container.*']

defaultSearch = 'skateboarding dog'
searchUrl = (query) -> "http://gdata.youtube.com/feeds/api/videos?v=2&alt=rss&q=#{query}"
watchUrl = (id) -> "http://www.youtube.com/v/#{id}?version=3"
thumbUrl = (id) -> "http://i.ytimg.com/vi/#{id}/default.jpg"
tc = (string) -> string[0].toUpperCase() + (string.substr 1)
withIndex = (index) -> (obj) ->
    obj.text = tc index
    obj.dataIndex = index
    obj

named = (name) -> (fn) ->
    { name: name, convert: (data,record) -> (fn record) }
withField = (id,fn) -> (record) -> (fn.call record.get(id), record.get(id))
Ext.define 'Video', {
    extend: 'Ext.data.Model',
    fields: ['guid','title','link','author','pubDate','description',
    (named 'shortdesc')(withField 'description', -> Ext.util.Format.ellipsis this, 240, true),
    (named 'date')(withField 'pubDate', Ext.util.Format.date)
    (named 'vid')(withField 'guid', -> (this.match /:([^:]+)$/)[1]),
    (named 'embed')(withField 'vid', watchUrl),
    (named 'thumbnail')(withField 'vid', thumbUrl)]
}

Ext.onReady () ->
    store = new Ext.data.Store {
        autoLoad: true,
        model: 'Video',
        proxy: {
            type: 'ajax',
            url: (searchUrl defaultSearch),
            reader: {
                type: 'xml',
                record: 'item',
                root: 'channel',
            },
        }
    }

    search = new Ext.form.field.Text {
        name: 'query',
        value: defaultSearch,
        fieldLabel: 'Search',
        enableKeyEvents: true,
    }

    grid = new Ext.grid.Panel {
        store: store,
        plugins: [{
            ptype: 'rowexpander',
            selectRowOnExpand: true,
            rowBodyTpl: ['<span class="iframe">{embed}</span><p class="description">{description}</p>']}],
        tbar: (new Ext.toolbar.Toolbar {items: [search]}),
        columns: [
            (withIndex 'title')({
                flex: 3,
                renderer: (value,p,record) ->
                    "<img class=\"thumbnail\" src=\"#{record.data.thumbnail}\" />" +
                    "<h1 class=\"title\">#{value}</h1>" +
                    "<p class=\"shortdesc\">#{record.data.shortdesc}</p>" +
                    "<a class=\"permalink\" href=\"#{record.data.link}\">Watch on YouTube</a>"}),
            (withIndex 'author')({flex: 1}),
            (withIndex 'date')({flex: 1})]
    }

    # Only load the iframe when the user expands the row
    grid.view.on 'expandbody', (fullRow, record, row) ->
        span = (row.querySelector 'span.iframe')
        if span
            video = span.innerText
            span.outerHTML = "<iframe class=\"video\" type=\"text/html\" allowfullscreen src=\"#{video}\" />" +
                "<p class=\"description\">#{record.data.description}</p>"

    # Search while typing
    search.on 'keyup', () ->
        store.getProxy().url = searchUrl this.value
        store.load()

    # Full-page view
    new Ext.Viewport {
        layout: 'fit',
        items: [grid],
    }
