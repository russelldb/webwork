#
# Cookbook Name:: erlang
# Recipe:: source
#
# Author:: Russell Brown (russell@ossme.net>)
# Copyright 2009, ossme.net
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
include_recipe "build-essential"

%w{ libssl-dev libncurses5-dev }.each do |devpkg|
  package devpkg
end

erl_version = node[:erlang][:version]

remote_file "/tmp/otp_src_#{erl_version}.tar.gz" do
  source "http://erlang.org/download/otp_src_#{erl_version}.tar.gz"
  action :create_if_missing
end

bash "compile_erl_source" do
  cwd "/tmp"
  code <<-EOH
    tar zxf otp_src_#{erl_version}.tar.gz
    cd otp_src_#{erl_version} && ./configure 
    make && make install
  EOH
  creates node[:erlang][:src_binary]
end
