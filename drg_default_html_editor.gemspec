$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "drg_default_html_editor/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "drg_default_html_editor"
  s.version     = DrgDefaultHtmlEditor::VERSION
  s.authors     = ["Damjan Rems"]
  s.email       = ["damjan.rems@gmail.com"]
  s.homepage    = "http://www.drgcms.org"
  s.summary     = "DRG CMS: Default HTML editor and file manager plugin"
  s.description = "DRG CMS: Default HTML editor and file manager plugin. Package includes of CK editor component and elFinder file manager component."
  s.license     = "MIT-LICENSE"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails" #, "~> 3.2.16"
  s.add_dependency "el_finder"  
  s.add_dependency "drg_cms"  
end
