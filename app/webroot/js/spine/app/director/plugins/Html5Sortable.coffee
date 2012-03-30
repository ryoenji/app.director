$.fn.html5Sortable = (type) ->
  $(@).Html5Sortable
    type: type
    drop: (source, target) -> return true

$.Html5Sortable = ->
    $.Html5Sortable.s_currentID = Math.floor(Math.random()*10000001)

  $.Html5Sortable.DRAGANDDROP_DEFAULT_TYPE = "de.webpremiere.html5sortable"
  
  $.Html5Sortable.s_currentID = 0
    
  $.Html5Sortable.defaultOptions =
    dragTarget:   (source) -> $(source)
    text:         (source) -> $('<div></div>').append($(source).clone(true)).html()
    css:       (source) ->
      el = ($(source))
      'height'        : el.css 'height'
      'padding-top'   : el.css 'padding-top'
      'padding-bottom': el.css 'padding-bottom'
      'margin-top'    : el.css 'margin-top'
      'margin-bottom' : el.css 'margin-bottom'
    klass:          (source) -> 'html5sortable-state-highlight'
    splitter:     (source) ->
      ($($('li.'+@klass())[0] or $('<li class="'+@klass()+'"></li>'))).css @css source
    type:         $.Html5Sortable.DRAGANDDROP_DEFAULT_TYPE,
    drop:         (source, target) -> false;

$.fn.Html5Sortable = (opts) ->
  options = $.extend {}, $.Html5Sortable.defaultOptions, opts

  # Set current ID
  $.Html5Sortable.s_currentID++
  
  # specific type
  if options.type is $.Html5Sortable.DRAGANDDROP_DEFAULT_TYPE
    options.type = options.type + '_' + $.Html5Sortable.s_currentID

  @each (index) ->
    that = $(@)
    that.init = (el) ->
      options.dragTarget(el).attr('draggable', true)
      .bind 'dragstart', (e) ->
        console.log index
        dt = e.originalEvent.dataTransfer
        dt.effectAllowed = 'move'
        dt.setData 'Text', JSON.stringify
          html:   options.text(el)
          type:   options.type
        Spine.sortItem =
          el: el
          data: el.data()
          splitter: options.splitter(@)
          
        # dt.setData("URL", options.type);
        $('._dragging').removeClass('_dragging')
        el.addClass('_dragging ')
        
      .bind 'dragend', (e) ->
        console.log 'Sort::dragend'
        $('._dragging').removeClass('_dragging')
#        try
#          unless (JSON.parse(e.originalEvent.dataTransfer.getData('Text')).type is options.type)
#            return true
#        catch e
#          return true
          
        Spine.sortItem.el?.addClass('in').removeClass('out in')
        
        Spine.sortItem.splitter.remove()

      .bind 'dragenter', (e) ->
        a = e.originalEvent.pageX
        b = $(@).position().left
        c = $(@).width()
        cond = (a - b) > c
        console.log cond
        if (cond)
          Spine.sortItem.splitter.insertAfter @
        else
          Spine.sortItem.splitter.insertBefore @
          
        Spine.sortItem.positionAfter = cond
          
        return false

      .bind 'dragleave', (e) ->
        try
          unless (e.originalEvent.dataTransfer.getData('Text') and JSON.parse(e.originalEvent.dataTransfer.getData('Text')).type is options.type)
            return true;
        catch e
          return true
        
        return false

      .bind 'drop', (e) ->
        positionAfter = Spine.sortItem.positionAfter
        try
          unless (JSON.parse(e.originalEvent.dataTransfer.getData('Text')).type is options.type)
            return true
        catch e
          return true
          
        sourceEl = $('._dragging')
        Spine.sortItem.splitter.remove()
        
        it = $(JSON.parse(e.originalEvent.dataTransfer.getData('Text')).html).addClass('out')
        it.data Spine.sortItem.data
        model = $(it).item().constructor.className

#        if options.drop(sourceEl.get(0), it.get(0))
#          # data not saved
#          console.log sourceEl.get(0)
#          console.log it.get(0)
#          it.remove()
#        else
        if (positionAfter)
          it.insertAfter @
        else
          it.insertBefore @

          sourceEl.remove()
          
          that.init it
          it.addClass('in')
          $('._dragging').removeClass('_dragging')
          it.removeClass('out in')
          Spine.Model[model].trigger('sortupdate', e, it)
        
    that.children('li').each ->
      that.init $(@)
