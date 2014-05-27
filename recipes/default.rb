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

node.normal[:mpd][:channels].each_value do |channel|
	# create socket
	file channel[:socket] do
	  action :touch
	end

	node.set[:mpd][:port] = channel[:port]
	node.set[:mpd][:db_file] = "/var/lib/mpd/tag_cache_" + channel[:name]
	node.set[:mpd][:bind_2] = channel[:socket]
	node.set[:mpd][:icecast_mountpoint] = "/" + channel[:name] + ".mp3"
	node.set[:mpd][:channel_name] = channel[:name]

	# create service
	service channel[:name] do
	  service_name "mpd" # linux service command
	  action :enable
	end

	config_filename = "/etc/" + channel[:name] + ".conf"
	template config_filename do
	  source "mpd.conf.erb"
	  mode "0644"
	  notifies :restart, resources(:service => channel[:name])
	end
end

