Spine         = require("spine")
Drag          = require("plugins/drag")
$             = Spine.$
Album         = require('models/album')
AlbumsPhoto   = require('models/albums_photo')
Info          = require('controllers/info')

require("plugins/tmpl")

class PhotoView extends Spine.Controller
  
  @extend Drag
  
  elements:
    '.hoverinfo'       : 'infoEl'
    '.items'           : 'items'
    '.items .item'     : 'item'
  
  events:
    'mousemove  .item'                : 'infoUp'
    'mouseleave .item'                : 'infoBye'
    'dragstart  .item'                : 'stopInfo'
    'dragstart  .items .thumbnail'    : 'dragstart'
    'dragenter  .items .thumbnail'    : 'dragenter'
    'drop       .items .thumbnail'    : 'drop'
    'dragend    .items .thumbnail'    : 'dragend'
    'dragenter'                       : 'dragenter'
    'drop'                            : 'drop'
    'dragend'                         : 'dragend'
    'click .glyphicon-set .back'           : 'back'
    
  template: (item) ->
    $('#photoTemplate').tmpl(item)
    
  infoTemplate: (item) ->
    $('#photoInfoTemplate').tmpl item
    
  constructor: ->
    super
    @el.data current: Photo
    @info = new Info
      el: @infoEl
      template: @infoTemplate
    @img = new Image
    @img.onload = @imageLoad
    
    Spine.bind('show:photo', @proxy @show)
    AlbumsPhoto.bind('destroy', @proxy @destroy)
    Photo.bind('update', @proxy @renderHeader)
    Photo.bind('destroy', @proxy @destroy)
    Spine.bind('change:selectedPhoto', @proxy @renderHeader)
    
  change: (item, changed) ->
    console.log 'PhotoView::change'
    @current = item
    @render()
    
  render: ->
    console.log 'PhotoView::render'
#    if Album.record
#      @el.removeClass 'all'
#    else
#      @el.addClass 'all'
    
    return unless @current
    @items.html @template @current
    @uri @current
    @renderHeader @current
    
  renderHeader: (item) ->
    @header.change item
  
  destroy: (item) ->
    console.log 'PhotoView::destroy'
    photoEl = @items.children().forItem @current
    photoEl.remove()
    Photo.current()
    delete @current
    @renderHeader()
    
  params: ->
    width: 600
    height: 451
    square: 2
    force: false
    
  uri: (item, mode = 'html') ->
    console.log 'PhotoView::uri'
    Photo.uri @params(),
      (xhr, record) => @callback(xhr, item),
      [Photo.record]
  
  callback: (json, item) =>
    console.log 'PhotoView::callback'
    
    searchJSON = (id) ->
      for itm in json
        return itm[id] if itm[id]
        
#    for item in items
    jsn = searchJSON item.id
    if jsn
      @img.element = $('.item', @items).forItem(item)
      @img.src = jsn.src
  
  imageLoad: ->
    el = $('.thumbnail', @element)
    img = $(@)
    w = @width
    h = @height
    
    el.html img
    .hide()
    .css
      'opacity'           : 0.01
    el.animate
      'width'             : w+'px'
      'height'            : h+'px'
    , complete: => img
      .css
        'opacity'         : 1
      .fadeIn()
      el.css
        'borderStyle'       : 'solid'
        'backgroundColor'   : 'rgba(255, 255, 255, 0.5)'
        'backgroundImage'   : 'none'
  
  deletePhoto: (e) ->
    item = $(e.currentTarget).item()
    return unless item?.constructor?.className is 'Photo' 
    
    el = $(e.currentTarget).parents('.item')
    el.removeClass('in')
    Album.updateSelection item.id
    
    window.setTimeout( ->
      Spine.trigger('destroy:photo')
    , 300)
    
    @stopInfo()
    e.stopPropagation()
    e.preventDefault()
  
  back: (e) ->
    @navigate '/gallery', Gallery.record.id, Album.record.id
    e.stopPropagation()
    e.preventDefault()
  
  infoUp: (e) =>
    @info.up(e)
    el = $('.glyphicon-set' , $(e.currentTarget)).addClass('in').removeClass('out')
    e.preventDefault()
    
  infoBye: (e) =>
    @info.bye()
    el = $('.glyphicon-set' , $(e.currentTarget)).addClass('out').removeClass('in')
    e.preventDefault()
    
  stopInfo: (e) =>
    @info.bye()
  
  show: (photo) ->
#    Photo.current(Photo.exists(photo.id))
    App.showView.trigger('change:toolbarOne', ['Default'])
    App.showView.trigger('canvas', @)
    @change photo
    
module?.exports = PhotoView