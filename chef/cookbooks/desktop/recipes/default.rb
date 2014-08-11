#
# Cookbook Name:: desktop
# Recipe:: default
#
# Copyright 2014, Jim Rosser
#
# All rights reserved - Do Not Redistribute
#

%w(
  elixir
  gdb
  libxml2-devel
  libxslt-devel
  gcc-c++
  gcc
  make
  cmake
  git
  mercurial
  bison
  docker-io
  irssi
  erlang
).each do |pkg|
  package pkg do
    action :install
  end
end

service 'docker' do
  action %i(enable start)
end
