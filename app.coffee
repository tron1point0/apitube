Ext.require ['Ext.data.*','Ext.grid.*']

Ext.define 'Video', {
    extend: 'Ext.data.Model',
    fields: ['title','link','author','pubDate'],
}

showVideo = (event,args...) ->
    event.preventDefault = true
    console.log

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
    search = Ext.create 'Ext.form.field.Text', {
        name: 'query',
        fieldLabel: 'Search',
        enableKeyEvents: true,
        onKeyUp: () ->
            store.getProxy().url = baseUrl + "&q=#{this.value}"
            store.load()
    }
    toolbar = Ext.create 'Ext.toolbar.Toolbar', {
        renderTo: document.body,
        items: [search],
    }
    grid = Ext.create 'Ext.grid.Panel', {
        renderTo: document.body,
        store: store,
        columns: [{
            text: 'Title',
            flex: 3,
            dataIndex: 'title',
            renderer: (value,p,record) ->
                Ext.String.format '<a href="{0}"">{1}</a>', record.data.link, value
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
    grid.on 'select', (args...) ->
        console.log args
