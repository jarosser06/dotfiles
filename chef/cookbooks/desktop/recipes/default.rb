#
# Cookbook Name:: desktop
# Recipe:: default
#
# Copyright 2014, Jim Rosser
#
# All rights reserved - Do Not Redistribute
#

pkgs = %w(
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
)

package 'req_packages' do
  package_name pkgs
  action :install
end
