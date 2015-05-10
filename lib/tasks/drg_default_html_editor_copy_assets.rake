require 'fileutils'

desc "Copy all assets from gem's assets folder to public/assets/ folder"
task "assets:precompile" do
  p 'Copying drg_default_html_editor assets to public/assets folder *****'
  
  input_dir  = File.realpath( File.dirname(__FILE__) + '/../../app/assets/javascripts/drg_default_html_editor')
  output_dir =  Rails.root.join('public/assets')
  cp_r(input_dir, output_dir, verbose: true)
end
