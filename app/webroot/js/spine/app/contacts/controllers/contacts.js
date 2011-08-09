jQuery(function($){
  
  window.Contacts = Spine.Controller.create({
    elements: {
      ".show"               : "showEl",
      ".edit"               : "editEl",
      ".show .content"      : "showContent",
      ".edit .content"      : "editContent"
    },
    
    events: {
      "click .optEdit"      : "edit",
      "click .optEmail"     : "email",
      "click .optDestroy"   : "destroy",
      "click .optSave"      : "save"
    },
    
    proxied: ["render", "show", "edit"],
    
    init: function(){
      this.editEl.hide();

      Contact.bind("change", this.render);
      this.App.bind("show:contact", this.show);
      this.App.bind("edit:contact", this.edit);
    },
    
    change: function(item){
      this.current = item;
      this.render();
    },
    
    render: function(){
      this.showContent.html($("#contactTemplate").tmpl(this.current));
      this.editContent.html($("#editContactTemplate").tmpl(this.current));
    },
    
    show: function(item){
      if (item && item.model) this.change(item);
      
      this.showEl.show();
      this.editEl.hide();
    },
    
    edit: function(item){
      if (item && item.model) this.change(item);
      
//      this.editEl.show();
//      this.showEl.hide();
      this.editEl.show(0, $.proxy(function() {
          this.showEl.hide();
      }, this));
    },
    
    destroy: function(){
      if (confirm("Are you sure?"))
        this.current.destroy();
    },
    
    email: function(){
      if ( !this.current.email ) return;
      window.location = "mailto:" + this.current.email;
    },
    
    save: function(){
      var atts = this.editEl.serializeForm();
      this.current.updateAttributes(atts);
      this.show();
    }
  });
  
})