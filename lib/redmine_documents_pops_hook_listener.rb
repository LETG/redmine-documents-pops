class RedmineDocumentsPopsHookListener < Redmine::Hook::ViewListener
  render_on :view_projects_show_right, partial: 'projects/pops_show_right'
end
