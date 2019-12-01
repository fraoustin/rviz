module Rviz
  module Hooks
    class ViewLayoutsBaseHtmlHeadHook < Redmine::Hook::ViewListener
      def view_layouts_base_html_head(context={})
        return javascript_include_tag('rviz.js', :plugin => 'rviz')
      end
    end
  end
end

