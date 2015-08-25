#
# Cookbook Name:: desktop
# Recipe:: default
#
# Copyright 2014, Jim Rosser
#
# All rights reserved - Do Not Redistribute
#

%w(
  bison
  cmake
  docker-io
  elixir
  erlang
  gcc
  gcc-c++
  gdb
  ghc
  ghc
  git
  irssi
  jq
  libxml2-devel
  libxslt-devel
  make
  mercurial
  fluid-soundfont-gm
).each do |pkg|
  package pkg do
    action :install
  end
end

service 'docker' do
  action %i(enable start)
end
