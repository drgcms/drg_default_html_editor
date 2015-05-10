module DrgDefaultHtmlEditor
#########################################################################
# Unfortunately this looks to be the only way to duplicate all files to target 
# directory. Add all files of interest to config.assets.precompile. 
#########################################################################
  class Engine < ::Rails::Engine
#    assets_dir = File.realpath( File.dirname(__FILE__) + '/../../app/assets/javascripts/drg_default_html_editor' )
#    initializer "drg_default_html_editor.assets_precompile" do |app|
#      Dir[assets_dir+'/**/*.{js,css,html,png,gif,jpg}'].each do |file|
#        app.config.assets.precompile << file.split('javascripts/').last
#      end
#    end
  end
end
