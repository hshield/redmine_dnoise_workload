require 'redmine'
require_dependency 'dateTools'
require_dependency 'list_user'
require_dependency 'calculos_tareas'

Redmine::Plugin.register :redmine_dnoise_workload do
  name 'Redmine Dnoise Workload plugin'
  description 'This is a plugin for Redmine Workload'
  version '2.1.1'
  url 'https://github.com/hshield/redmine_dnoise_workload'

  project_module :workload do
    permission :view_workload, {:work_load => [:index, :show] }
  end

  menu :top_menu, :WorkLoad, { :controller => 'work_load', :action => 'show', :show_issues => '1' },
	:caption => :workload_title,
	:if => Proc.new {
		User.current.allowed_to?(:view_workload, nil, :global => true)
	}

  #permission :WorkLoad, {:work_load => [:index ] }, :public => true
  #menu :project_menu, :WorkLoad, { :controller => 'work_load', :action => 'index' }, :caption => 'WorkLoad'


end

class RedmineToolbarHookListener < Redmine::Hook::ViewListener
   def view_layouts_base_html_head(context)
     stylesheet_link_tag('style', :plugin => :redmine_dnoise_workload )
   end
end
