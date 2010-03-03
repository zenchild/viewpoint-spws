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
require 'singleton'
#
require 'config_loader'
# Load the backend SOAP infrastructure.  Today this is Handsoap.
require 'soap/soap_provider'
# Load the model classes
require 'model/sp_list'
require 'model/sp_list_item'
require 'model/sp_field'
require 'model/sp_user'

module Viewpoint
  module SPWS
    class SPWS
      include Singleton

      attr_reader :list_ws, :web_ws, :copy_ws, :usergroup_ws, :sitedata_ws

      def initialize
        @list_ws = SOAP::ListService.new
        @web_ws  = SOAP::WebService.new
        @copy_ws  = SOAP::CopyService.new
        @usergroup_ws  = SOAP::UserGroupService.new
        @sitedata_ws = SOAP::SiteDataService.new
      end

      def lists
        @list_ws.get_list_collection
      end

      def get_list(title)
        @list_ws.get_list(title)
      end

    end
  end # SPWS
end # Viewpoint
