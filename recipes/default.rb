#
# Cookbook Name:: mpd
# Recipe:: default
#
# Copyright 2011, Chris Peplin
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

package "mpd"

# mpd: {
#   channels: {
#     mix: {
#       name: 'mpd_mix',
#       bind: '0.0.0.0',
#       socket: '/home/vagrant/.mpd/socket/mix',
#       port: '6600'
#     },
#     tech: {
#       name: 'tech',
#       bind: '0.0.0.0',
#       socket: '/home/vagrant/.mpd/socket/tech',
#       port: '6601'
#   }
#   }
# },

node[:mpd][:channels].each_value do |channel|

	# create socket
	file channel[:socket] do
	  action :touch
	end

	# create init file
	init_filename = "/etc/init.d/" + channel[:name]
	template init_filename do
	  variables :channel => channel
	  source "mpd.init.erb"
	  mode "0755"
	end

	# create service
	service channel[:name] do
	  service_name channel[:name] # linux service command
	  action :enable
	end

	# create config file
	config_filename = "/etc/" + channel[:name] + ".conf"
	template config_filename do
	  variables :channel => channel
	  source "mpd.conf.erb"
	  mode "0644"
	  notifies :restart, resources(:service => channel[:name])
	end

end

