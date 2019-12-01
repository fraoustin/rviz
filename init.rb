# encoding: utf-8
require 'redmine'
require_dependency 'rviz'
Redmine::Plugin.register :rviz do
  name 'Redmine Viz'
  author 'Frederic Aoustin'
  description 'The RViz add viz.js in Redmine.'
  version '0.1.0'
  url 'https://github.com/fraoustin/rviz'
  author_url 'https://github.com/fraoustin'
end
