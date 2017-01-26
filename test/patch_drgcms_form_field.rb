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
DrgcmsFormField rescue nil  # force loading of drgcms_form_field.rb in development ;-)

module DrgcmsFormField

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
           height: 490,
           docked: false,
           dialog: { width: 400, modal: true },
           lang: '#{I18n.locale}',
           getFileCallback : function(file) {
             file = file.replace('//','/');
             $('##{record}_#{@yaml['name']}').val(file);
             $('##{record}_div_#{@yaml['name']}').hide();
           },
   });
});
EOJS

  @html << @parent.text_field(record, @yaml['name'], @yaml['html']) +
           "<div id='#{record}_div_#{@yaml['name']}'></div>".html_safe
  self
end

###########################################################################
# Return html url code required for FileManager icon on CMS menu.
###########################################################################
def self.file_manager_url(parent)
  url = "/assets/elfinder/elfinder.html?CKEditorFuncNum=1&langCode=#{I18n.locale}"
        
  parent.link_to( parent.image_tag('drg_cms/file_manager.png', 
                                    class: 'dc-link-img', 
                                    title: parent.t('drgcms.file_manager')),
                                    '#',
                                    { onclick: "window.open('#{url}',
                                               '#{parent.t('drgcms.file_manager')}',
                                               'width=700,height=500')"} ) 
end

end

###########################################################################
# Class for creating ckeditor DRG CMS form field.
###########################################################################
class Ckeditor < DrgcmsField
  
###########################################################################
# Return code required to render ckeditor DRG CMS form field.
###########################################################################
def render
  return ro_standard if @readonly
  set_initial_value
# read configuration from site settings
  ck_config = '/assets/ckeditor_config.js'
  ck_css    = '/assets/ckeditor_css.css' 
  ck = @parent.dc_get_site ? @parent.dc_get_site.params['ck_editor'] : nil # site might not be available yet
  if ck
    ck_config = ck['config_file'] if ck['config_file']
    ck_css    = ck['css_file'] if ck['css_file']
  end
#  
  @yaml['options'] ||= ''
  @yaml['options'] << ", customConfig: '#{ck_config}'"
  @yaml['options'] << ", contentsCss: '#{ck_css}'" unless ck_css.blank?
  @yaml['options'] << ", language: '#{I18n.locale}'" unless @yaml['options'].match('language:')
  
  options = @yaml['options'] ? ",{#{@yaml['options']}}" : ''
  record = record_text_for(@yaml['name'])
  @html << @parent.text_area(record, @yaml['name'], @yaml['html']) 
  @js << "CKEDITOR.replace( '#{record}_#{@yaml['name']}'#{options} );"
  self
end
end

end