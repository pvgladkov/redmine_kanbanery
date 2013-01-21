require 'redmine'
require 'httparty'

require_dependency 'kanbanery/hooks'

Redmine::Plugin.register :redmine_kanbanery do
  name 'Redmine Kanbanery plugin'
  author 'Paul Gladkov'
  description 'This plugins allows one to push issues to kanbanery.com'
  version '0.1.0'
  url 'http://github.com/webgeist/redmine_kanbanery'
  author_url 'http://github.com/webgeist'


  permission :push_to_kanbanery, {:kanbanery => :push}
  settings :default => {
      'api_key' => '', 'workspace_name' => '', 'project_id' => '', 'auth_token' => '','auth_token_2' => '', 'closed_status_name' => ''
  }, :partial => 'settings/settings'
end
