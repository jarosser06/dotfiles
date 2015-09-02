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
  java-1.8.0-openjdk
  java-1.8.0-openjdk-src
  java-1.8.0-openjdk-devel
).each do |pkg|
  package pkg do
    action :install
  end
end

service 'docker' do
  action %i(enable start)
end
