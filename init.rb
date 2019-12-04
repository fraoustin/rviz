# encoding: utf-8


require 'redmine'
begin
  require 'config/initializers/session_store.rb'
  rescue LoadError
end

def init_rviz
  Dir::foreach(File.join(File.dirname(__FILE__), 'lib')) do |file|
    next unless /\.rb$/ =~ file
    require_dependency file
  end
end

if Rails::VERSION::MAJOR >= 5
  ActiveSupport::Reloader.to_prepare do
    init_rviz
  end
elsif Rails::VERSION::MAJOR >= 3
  ActionDispatch::Callbacks.to_prepare do
    init_rviz
  end
else
  Dispatcher.to_prepare :rviz do
    init_rviz
  end
end

require File.expand_path('../../../lib/redmine/wiki_formatting/textile/redcloth3', __FILE__)
Redmine::Plugin.register :rviz do
  name 'Redmine Viz'
  author 'Frederic Aoustin'
  description 'The RViz add viz.js in Redmine.'
  version '0.1.0'
  url 'https://github.com/fraoustin/rviz'
  author_url 'https://github.com/fraoustin'
  requires_redmine :version_or_higher => '2.3.0'

  RedCloth3::ALLOWED_TAGS << "div"
end
