#
# Cookbook Name:: riak
# Recipe:: defaults
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


riak_version = node[:riak][:version]

remote_file "/tmp/riak-#{riak_version}.tar.gz" do
  source "http://hg.basho.com/riak/downloads/riak-#{riak_version}.tar.gz"
  action :create_if_missing
end

bash "compile_riak_source" do
  cwd "/tmp"
  code <<-EOH
    tar zxf riak-#{riak_version}.tar.gz
    cd riak-#{riak_version} 
    make rel
    mkdir -p /usr/local/riak
    mv rel /usr/local/riak
  EOH
end
