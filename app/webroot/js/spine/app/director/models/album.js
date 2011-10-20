var Album;
var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
  for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
  function ctor() { this.constructor = child; }
  ctor.prototype = parent.prototype;
  child.prototype = new ctor;
  child.__super__ = parent.prototype;
  return child;
};
Album = (function() {
  __extends(Album, Spine.Model);
  function Album() {
    Album.__super__.constructor.apply(this, arguments);
  }
  Album.configure("Album", "name", 'title', 'description', 'user_id');
  Album.extend(Spine.Model.Ajax);
  Album.extend(Spine.Model.AjaxRelations);
  Album.extend(Spine.Model.Filter);
  Album.extend(Spine.Model.Extender);
  Album.selectAttributes = ["name"];
  Album.url = function() {
    return '' + base_url + this.className.toLowerCase() + 's';
  };
  Album.nameSort = function(a, b) {
    var aa, bb, _ref, _ref2;
    aa = (_ref = (a || '').name) != null ? _ref.toLowerCase() : void 0;
    bb = (_ref2 = (b || '').name) != null ? _ref2.toLowerCase() : void 0;
    if (aa === bb) {
      return 0;
    } else if (aa < bb) {
      return -1;
    } else {
      return 1;
    }
  };
  Album.foreignModels = function() {
    return {
      'Gallery': {
        className: 'Gallery',
        joinTable: 'GalleriesAlbum',
        foreignKey: 'album_id',
        associationForeignKey: 'gallery_id'
      },
      'Image': {
        className: 'Image',
        joinTable: 'AlbumsImage',
        foreignKey: 'album_id',
        associationForeignKey: 'image_id'
      }
    };
  };
  Album.prototype.init = function(instance) {
    if (!instance) {}
  };
  Album.prototype.selectAttributes = function() {
    var attr, result, _i, _len, _ref;
    result = {};
    _ref = this.constructor.selectAttributes;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      attr = _ref[_i];
      result[attr] = this[attr];
    }
    return result;
  };
  Album.prototype.select = function(id) {
    var ga, record, _i, _len;
    ga = GalleriesAlbum.filter(id);
    for (_i = 0, _len = ga.length; _i < _len; _i++) {
      record = ga[_i];
      if (record.album_id === this.id) {
        return true;
      }
    }
  };
  return Album;
})();
Spine.Model.Album = Album;