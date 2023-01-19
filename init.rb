require File.join(File.dirname(__FILE__), 'lib/redmine_documents_pops_hook_listener')
require File.join(File.dirname(__FILE__), 'app/models/documents_pops')
require File.join(File.dirname(__FILE__), 'app/models/attachments_pops')
# require File.join(File.dirname(__FILE__), 'app/helpers/attachments_helper_patch')
require File.join(File.dirname(__FILE__), 'app/controllers/documents_controller_patch')
require File.join(File.dirname(__FILE__), 'app/controllers/attachments_controller_patch')

Redmine::Plugin.register :documents_pops do
  name 'Documents Pops plugin'
  author 'Dotgeee'
  description 'Plugins for documents'
  version '0.0.1'
  url 'http://example.com/path/to/plugin'
  author_url 'http://example.com/about'
end




