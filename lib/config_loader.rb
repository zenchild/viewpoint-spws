#############################################################################
# Copyright © 2010 Dan Wanek <dan.wanek@gmail.com>
#
#
# This file is part of Viewpoint.
# 
# Viewpoint is free software: you can redistribute it and/or
# modify it under the terms of the GNU General Public License as published
# by the Free Software Foundation, either version 3 of the License, or (at
# your option) any later version.
# 
# Viewpoint is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
# Public License for more details.
# 
# You should have received a copy of the GNU General Public License along
# with Viewpoint.  If not, see <http://www.gnu.org/licenses/>.
#############################################################################
module Viewpoint
  module Sharepoint
    module ConfigLoader

      def load_config!(config = "#{ENV['HOME']}/.viewpointrc")
        begin
          @@config = YAML.load_file(config)
        rescue Errno::ENOENT => e
          manual_config
        end

        raise TypeError, "Configuration should be a Hash, but is of type #{config.class.to_s}" unless @@config.instance_of?(Hash)
      end

      def manual_config
        require 'highline/import'
        ep = ask("Which Sharepoint site are you configuring? ") { |q| q.echo = true }
        user = ask("User: ") { |q| q.echo = true }
        pass = ask("Pass: ") { |q| q.echo = "*"}
        @@config = {ep => {:user => user, :pass => pass},
          :default => {:user => user, :pass => pass}}
        save_config!
      end

      def save_config!(config = "#{ENV['HOME']}/.viewpointrc")
        File.open(config,'w+') do |f|
          f.write(@@config.to_yaml)
        end
      end

    end
  end # Sharepoint
end # Viewpoint
