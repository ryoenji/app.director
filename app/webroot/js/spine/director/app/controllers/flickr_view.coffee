Spine = require('spine')
ToolbarView = require("controllers/toolbar_view")

class FlickrView extends Spine.Controller

  elements:
    '.links'      : 'links'
    '.content'    : 'content'
    '.toolbar'    : 'toolbarEl'
    
  events:
    'click .links'    : 'click'
    'click .optPrev'  : 'prevPage'
    'click .optNext'  : 'nextPage'
    
  template: (items) ->
    $('#flickrTemplate').tmpl items
    
  toolsTemplate: (items) ->
    $("#toolsTemplate").tmpl items
    
  constructor: ->
    super
    @type = 'recent'
    @perpage = 100
    @spec = 
      recent:
        min     : 1
        page    : 1
        pages   : 5
        per_page: @perpage
      inter:
        min     : 1
        page    : 1
        pages   : 5
        per_page: @perpage
    @toolbar = new ToolbarView
      el: @toolbarEl
      template: @toolsTemplate
      
    @bind('flickr:recent', @proxy @recent)
    @bind('flickr:inter', @proxy @interestingness)
      
  render: (items) ->
    @content.html @template items
    
  url: ->
    protocol = if window.location.protocol is 'https:'
      'https://secure'
    else
      'http://api'
    protocol + '.flickr.com/services/rest/'
                
  data:
    format  : 'json',
    method  : 'flickr.photos.getRecent',
    api_key : '7617adae70159d09ba78cfec73c13be3'
    
  setup: (mode, page) ->
    console.log 'FlickrView::setup'
    @type = mode
    switch mode
      when 'recent'
        toolsList = ['FlickrRecent']
        options =
          page  : page || @spec[mode].page
          method: 'flickr.photos.getRecent'
      when 'inter'
        toolsList = ['FlickrInter']
        options =
          page  : page || @spec[mode].page
          method: 'flickr.interestingness.getList'
      else
        return
    options = $().extend @spec[mode], options
    @changeToolbar toolsList if toolsList
    @ajax(options)
    
  ajax: (options) ->
    console.log 'FlickrView::ajax'
    data = $().extend @data, options
    $.ajax(
      url: @url()
      data: data
      dataType: 'jsonp',
      jsonp: 'jsoncallback'
    )
    .done(@doneResponse)
    .fail(@failResponse)
    
  doneResponse: (result) =>
    # update our own spec object with flickrs response
    @updateSpecs result
    @render result.photos.photo
    
  failResponse: (args...) ->
    console.log args
    
  changeToolbar: (list) ->
    @toolbar.change list
    @refreshElements()
    
  click: (e) ->
    e.stopPropagation()
    e.preventDefault()
    
    target = $(e.target).parent()[0]
    options = index: target
    links = $('a', @links)
    gallery = blueimp.Gallery(links, options)
    
  prevPage: (e) ->
    e.stopPropagation()
    e.preventDefault()
    type = @type
    @spec[type].page = if (t = ((@spec[type].page || 1)-1)) >= 1 then t else 1
    @navigate '/flickr', type, @spec[type].page
  
  nextPage: (e) ->
    e.stopPropagation()
    e.preventDefault()
    type = @type
    @spec[type].page = if (t = ((@spec[type].page || 1)+1)) <= @spec[type].pages then t else @spec[type].pages
    @navigate '/flickr', type, @spec[type].page
    
  details: (type) ->
    page = (Number) @spec[type].page
    perpage = (Number) @spec[type].per_page
    from: ((page-1) * perpage) + 1
    to: ((page-1) * perpage) + perpage
    
  updateSpecs: (res) ->
    type = @type
    $().extend @spec[type], res.photos
    # prevent flickr from choking on nested objects
    delete @spec[type].photo

  recent: (page) ->
    console.log 'FlickrView::recent'
    expander = App.sidebarFlickr.expander
    expander.click() unless expander.hasClass('open')
    @setup('recent', page)
    
  interestingness: (page) ->
    console.log 'FlickrView::interestingness'
    expander = App.sidebarFlickr.expander
    expander.click() unless expander.hasClass('open')
    @setup('inter', page)
    

module.exports = FlickrView