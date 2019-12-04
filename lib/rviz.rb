module Rviz
  module Hooks
    class ViewLayoutsBaseHtmlHeadHook < Redmine::Hook::ViewListener
      def view_layouts_base_html_head(context={})
        return javascript_include_tag('rviz.js', :plugin => 'rviz') +
          stylesheet_link_tag('rviz.css', :plugin => 'rviz')  
      end
    end
  end
end

module RvizMacro
  Redmine::WikiFormatting::Macros.register do
    desc "Adds a graphviz code:\n\n" +
      "<pre>\n" +
      "{{graphviz\na->b;\nb->;\n\n}}\n" +
      "</pre>"
    macro :graphviz, :parse_args => false do |obj, args, text|
      content_tag('div', text, :class => "graphviz "+args)
    end

  end

end
