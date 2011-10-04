var $, AlbumsShowView;
var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
  for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
  function ctor() { this.constructor = child; }
  ctor.prototype = parent.prototype;
  child.prototype = new ctor;
  child.__super__ = parent.prototype;
  return child;
};
if (typeof Spine !== "undefined" && Spine !== null) {
  Spine;
} else {
  Spine = require("spine");
};
$ = Spine.$;
AlbumsShowView = (function() {
  __extends(AlbumsShowView, Spine.Controller);
  AlbumsShowView.extend(Spine.Controller.Drag);
  AlbumsShowView.prototype.elements = {
    ".content": "showContent",
    "#views .views": "views",
    ".content .sortable": "sortable",
    '.optGallery': 'btnGallery',
    '.optAlbum': 'btnAlbum',
    '.optUpload': 'btnUpload',
    '.optGrid': 'btnGrid',
    '.content .items': 'items',
    '.content .items .item': 'item',
    '.header': 'header',
    '.toolbar': 'toolBar'
  };
  AlbumsShowView.prototype.events = {
    "click .optCreateAlbum": "create",
    "click .optDeleteAlbum": "destroy",
    "click .optEdit": "edit",
    "click .optEmail": "email",
    "click .optGallery": "toggleGallery",
    "click .optAlbum": "toggleAlbum",
    "click .optUpload": "toggleUpload",
    "click .optGrid": "toggleGrid",
    'dblclick .draghandle': 'toggleDraghandle',
    'dragstart          .items .item': 'dragstart',
    'dragenter          .items .item': 'dragenter',
    'dragover           .items .item': 'dragover',
    'dragleave          .items .item': 'dragleave',
    'drop               .items .item': 'drop',
    'dragend            .items .item': 'dragend'
  };
  AlbumsShowView.prototype.albumsTemplate = function(items) {
    return $("#albumsTemplate").tmpl(items);
  };
  AlbumsShowView.prototype.toolsTemplate = function(items) {
    return $("#toolsTemplate").tmpl(items);
  };
  function AlbumsShowView() {
    AlbumsShowView.__super__.constructor.apply(this, arguments);
    this.list = new Spine.AlbumList({
      el: this.items,
      template: this.albumsTemplate
    });
    Album.bind("create", this.proxy(this.createJoin));
    Album.bind("destroy", this.proxy(this.destroyJoin));
    Spine.bind("destroy:albumJoin", this.proxy(this.destroyJoin));
    Album.bind("change", this.proxy(this.render));
    Gallery.bind("update", this.proxy(this.renderHeader));
    Spine.bind('save:gallery', this.proxy(this.save));
    Spine.bind('change:selectedGallery', this.proxy(this.change));
    GalleriesAlbum.bind("destroy", this.proxy(this.confirmed));
    GalleriesAlbum.bind("change", this.proxy(this.render));
    this.bind('save:gallery', this.proxy(this.save));
    this.bind("toggle:view", this.proxy(this.toggleView));
    this.toolBarList = [];
    this.create = this.edit;
    $(this.views).queue("fx");
  }
  AlbumsShowView.prototype.confirmed = function(ga) {
    if (!ga.destroyed) {
      return alert(ga.name + 'NOT destroyed');
    }
  };
  AlbumsShowView.prototype.children = function(sel) {
    return this.el.children(sel);
  };
  AlbumsShowView.prototype.loadJoinTables = function() {
    return AlbumsImage.records = Album.joinTableRecords;
  };
  AlbumsShowView.prototype.change = function(item, mode) {
    console.log('AlbumsShowView::change');
    if (mode) {
      console.log(mode);
    }
    this.current = item;
    this.render();
    return typeof this[mode] === "function" ? this[mode](item) : void 0;
  };
  AlbumsShowView.prototype.render = function(album) {
    var items;
    console.log('AlbumsShowView::render');
    if (this.current) {
      items = Album.filter(this.current.id);
    } else {
      items = Album.filter();
    }
    this.renderHeader();
    return this.list.render(items, (album instanceof Album ? album : void 0));
  };
  AlbumsShowView.prototype.renderHeader = function(item) {
    var gallery;
    console.log('AlbumsShowView::renderHeader');
    gallery = item || this.current;
    if (gallery) {
      return this.header.html('<h2>Albums for Gallery ' + gallery.name + '</h2>');
    } else {
      return this.header.html('<h2>Albums Overview</h2>');
    }
  };
  AlbumsShowView.prototype.renderToolBar = function() {
    this.toolBar.html(this.toolsTemplate(this.toolBarList));
    return this.refreshElements();
  };
  AlbumsShowView.prototype.initSortables = function() {
    var sortOptions;
    sortOptions = {};
    return this.sortable.sortable(sortOptions);
  };
  AlbumsShowView.prototype.create = function() {
    return Spine.trigger('createAlbum');
  };
  AlbumsShowView.prototype.destroy = function() {
    return Spine.trigger('destroyAlbum');
  };
  AlbumsShowView.prototype.createJoin = function(album) {
    var ga;
    console.log('AlbumsShowView::createJoin');
    console.log(album);
    if (!Gallery.record) {
      return;
    }
    ga = new GalleriesAlbum({
      gallery_id: Gallery.record.id,
      album_id: album.id
    });
    return ga.save();
  };
  AlbumsShowView.prototype.destroyJoin = function(album) {
    console.log('AlbumsShowView::destroyJoin');
    return GalleriesAlbum.each(function(record) {
      if (record.gallery_id === Gallery.record.id && album.id === record.album_id) {
        return record.destroy();
      }
    });
  };
  AlbumsShowView.prototype.edit = function() {
    App.albumsEditView.render();
    return App.albumsManager.change(App.albumsEditView);
  };
  AlbumsShowView.prototype.email = function() {
    if (!this.current.email) {
      return;
    }
    return window.location = "mailto:" + this.current.email;
  };
  AlbumsShowView.prototype.renderViewControl = function(controller, controlEl) {
    var active;
    active = controller.isActive();
    $(".options .opt").each(function() {
      if (this === controlEl) {
        return $(this).toggleClass("active", active);
      } else {
        return $(this).removeClass("active");
      }
    });
    if (!App.hmanager.hasActive()) {
      return this.toolBar.empty();
    }
  };
  AlbumsShowView.prototype.animateView = function() {
    var hasActive, height;
    hasActive = function() {
      if (App.hmanager.hasActive()) {
        return App.hmanager.enableDrag();
      }
      return App.hmanager.disableDrag();
    };
    height = function() {
      if (hasActive()) {
        return parseInt(App.hmanager.currentDim) + "px";
      } else {
        return "7px";
      }
    };
    return this.views.animate({
      height: height()
    }, 400);
  };
  AlbumsShowView.prototype.toggleGallery = function(e) {
    this.toolBarList = [
      {
        name: 'Show Gallery',
        klass: 'optEdit'
      }, {
        name: 'Edit Gallery',
        klass: 'optEdit'
      }
    ];
    return this.trigger("toggle:view", App.gallery, e.target);
  };
  AlbumsShowView.prototype.toggleAlbum = function(e) {
    this.toolBarList = [
      {
        name: 'Create Album',
        klass: 'optCreateAlbum'
      }, {
        name: 'Delete Album',
        klass: 'optDeleteAlbum'
      }
    ];
    return this.trigger("toggle:view", App.album, e.target);
  };
  AlbumsShowView.prototype.toggleUpload = function(e) {
    this.toolBarList = [
      {
        name: 'Show Upload',
        klass: 'optEdit'
      }, {
        name: 'Edit Upload',
        klass: 'optEdit'
      }
    ];
    return this.trigger("toggle:view", App.upload, e.target);
  };
  AlbumsShowView.prototype.toggleGrid = function(e) {
    this.toolBarList = [
      {
        name: 'Show Grid',
        klass: 'optEdit'
      }, {
        name: 'Edit Grid',
        klass: 'optEdit'
      }
    ];
    return this.trigger("toggle:view", App.grid, e.target);
  };
  AlbumsShowView.prototype.toggleView = function(controller, control) {
    var isActive;
    isActive = controller.isActive();
    if (isActive) {
      App.hmanager.trigger("change", false);
    } else {
      this.activeControl = $(control);
      App.hmanager.trigger("change", controller);
    }
    this.renderToolBar();
    this.renderViewControl(controller, control);
    return this.animateView();
  };
  AlbumsShowView.prototype.toggleDraghandle = function() {
    return this.activeControl.click();
  };
  return AlbumsShowView;
})();
if (typeof module !== "undefined" && module !== null) {
  module.exports = AlbumsView;
}