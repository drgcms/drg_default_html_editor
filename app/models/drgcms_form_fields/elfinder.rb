#--
# Copyright (c) 2012+ Damjan Rems
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#++

module DrgcmsFormFields
  
###########################################################################
# Class for creating ElFinder file manager enabled form field.
###########################################################################
class Elfinder < DrgcmsField
  
###########################################################################
# Return code required to render elfinder DRG CMS form field.
###########################################################################
def render
  return ro_standard if @readonly
  set_initial_value
#
 record = record_text_for(@yaml['name'])
 @js << <<EOJS

$('##{record}_#{@yaml['name']}').dblclick(function(){
   $('##{record}_div_#{@yaml['name']}').show();
   var f = $('##{record}_div_#{@yaml['name']}').elfinder({
           url : '/elfinder',
           transport : new elFinderSupportVer1(),
           rememberLastDir: true,
           height: 490,
           docked: false,
           dialog: { width: 400, modal: true },
           lang: '#{I18n.locale}',
           getFileCallback : function(files) {
             console.log(files);
             $('##{record}_#{@yaml['name']}').val(files.url);
             $('##{record}_div_#{@yaml['name']}').hide();
           },
   });
});
EOJS

  @html << @parent.text_field(record, @yaml['name'], @yaml['html'])
  unless @record[@yaml['name']].blank? or @parent.dc_dont?(@yaml['preview'], false)
    @html << 
%Q[<span class="dc-image-preview">
#{(@parent.image_tag(@record[@yaml['name']], title: t('drgcms.img_large') ) unless @record[@yaml['name']].match('<i ')) rescue ''}
</span><div id="dc-image-preview"></div>]
  end  
  @html << "<div id='#{record}_div_#{@yaml['name']}'></div>"        
         
  self
end

###########################################################################
# Return html url code required for FileManager icon on CMS menu.
###########################################################################
def self.file_manager_url(parent)
  url = "/assets/elfinder/elfinder.html?CKEditorFuncNum=1&langCode=#{I18n.locale}"
        
  parent.link_to( parent.fa_icon('inventory_2-o', title: parent.t('drgcms.file_manager')), '#',
                 { onclick: "window.open('#{url}', '#{parent.t('drgcms.file_manager')}',
                  'width=700,height=500')"} ) 
end

end

end
