#--
# Copyright (c) 2014+ Damjan Rems
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

module ElFinder
class Connector
  
private
#######################################################################
# Will only move selected files to .trash folder instead of remove them.
# 
# The only problem I see is that if user has rights to perform remove parent
# folder but not some of its children, whole parent folder will be moved to .trash.
#######################################################################
def remove_target(target)
  if perms_for(target)[:rm] == false
    @response[:error] ||= 'Some files/directories were unable to be removed'
    @response[:errorData][target.basename.to_s] = "Access Denied"
    return
  end
# create trash folder if it doesn't exist
  trash_dir = File.join(@root,'.trash/')
  FileUtils.mkdir(trash_dir) unless File.exist?(trash_dir)
#  
  begin
    FileUtils.mv(target, trash_dir, :force => true )
    if !target.directory?
      if @options[:thumbs] && (thumbnail = thumbnail_for(target)).file?
        FileUtils.mv(thumbnail, trash_dir, :force => true )
      end
    end
  rescue
    @response[:error] ||= 'Some files/directories were unable to be removed'
    @response[:errorData][target.basename.to_s] = "Remove failed"
  end
end

#######################################################################
# Return permissions for a file or directory. This overwrites default 
# behavior and inserts drgcms users roles.
#######################################################################
def perms_for(pathname, options = {})
  if @permissions.nil?
    @permissions = {}
# find root name and get all rules, that are for descendent of root.
# There can be more than one root, because each site can have its own root
    root = pathname.root.to_s.sub(Rails.root.join('public').to_s,'')
    DcFolderPermission.where(folder_name: /#{root}*/).sort(folder_name: 1).each do |permission|
      folder = permission.folder_name.sub(root,'')
      folder.gsub!(/^\/|\/$/, '')
# root is always ., remove leading and trailing /
      folder = '.' if folder.blank?
# no rights by default. 
      h = {read: false, write: false, rw: false, inherited: permission.inherited}
# go through policy_rules and set rights if role matches rules role 
      permission.dc_policy_rules.each do |r|
        @options[:user_roles].each do |role|
          next unless role == r.dc_policy_role_id
          h[:read]  ||= r.permission > 0
          h[:write] ||= r.permission > 1
          h[:rw]    ||= r.permission > 8
        end
        @permissions[folder] = h 
      end
    end
  end
# create response. First check for defaults of root folder
  response = {}
  response[:read]  = pathname.exist? && @permissions['.'][:read]
  response[:write] = pathname.exist? && @permissions['.'][:write]
  response[:rm]    = !pathname.is_root? && @permissions['.'][:rw]
  dir = ''
# go through every subfolder part. Policy is: if right has been revoked on 
# parent folder it can't be set on child unless inherited is false.
  pathname.path.to_s.split('/').each do |path|
    dir << (dir.size > 0 ? '/' : '') + path
    pe = @permissions[dir]
    next if pe.nil?     # ignore if not set
    if pe[:inherited]
      response[:read]  &&= pe[:read]
      response[:write] &&= pe[:write]
      response[:rm]    &&= pe[:rw]
    else
      response[:read]  = pe[:read]
      response[:write] = pe[:write]
      response[:rm]    = pe[:rw]
    end       
  end
  response[:hidden] = false
  response
end # of perms_for


end
end
