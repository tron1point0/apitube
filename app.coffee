Ext.Loader.setConfig {
    enabled: true,
}
Ext.Loader.setPath 'Ext.ux', 'extjs-4.1.0/examples/ux'
Ext.require ['Ext.data.*','Ext.grid.*','Ext.ux.RowExpander','Ext.container.*']

Ext.define 'Video', {
    extend: 'Ext.data.Model',
    fields: ['title','link','author','pubDate',{
        name: 'embed',
        type: 'string',
        defaultValue: '',
        convert: (value,record) ->
            matches = ((record.get 'link').match /v=(\w+)/)
            id = matches[1] if matches
            "http://www.youtube.com/v/#{id}?version=3"
    }],
}

Ext.onReady () ->
    baseUrl = 'http://gdata.youtube.com/feeds/api/videos?v=2&alt=rss'
    store = Ext.create 'Ext.data.Store', {
        autoLoad: true,
        model: 'Video',
        proxy: {
            type: 'ajax',
            url: baseUrl,
            reader: {
                type: 'xml',
                record: 'item',
                root: 'channel',
            },
        }
    }
    grid = Ext.create 'Ext.grid.Panel', {
        store: store,
        plugins: [{
            ptype: 'rowexpander',
            selectRowOnExpand: true,
            rowBodyTpl: ['<span class="iframe">{embed}</span>'],
        }],
        tbar: (Ext.create 'Ext.toolbar.Toolbar', {
            items: [Ext.create 'Ext.form.field.Text', {
                name: 'query',
                fieldLabel: 'Search',
                enableKeyEvents: true,
                onKeyUp: () ->
                    store.getProxy().url = baseUrl + "&q=#{this.value}"
                    store.load()
            }],
        }),
        columns: [{
            text: 'Title',
            flex: 3,
            dataIndex: 'title',
            renderer: (value,p,record) -> "<a href=\"#{record.data.link}\">#{value}</a>",
        },{
            text: 'Author',
            flex: 1,
            dataIndex: 'author',
        },{
            text: 'Date',
            flex: 2,
            dataIndex: 'pubDate',
        }],
    }
    # Only load the iframe when the user expands the row
    grid.view.on 'expandbody', (fullRow, record, row) ->
        span = (row.querySelector 'span.iframe')
        video = span.innerText
        span.innerHTML = "<iframe type=\"text/html\" width=\"640\" height=\"480\" frameborder=\"0\" allowfullscreen src=\"#{video}\" />"
    new Ext.Viewport {
        layout: 'fit',
        items: [grid],
    }
