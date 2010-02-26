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
  module SPWS
    class SPList

      attr_accessor :id, :title, :description, :default_view_url, :web_full_url, :server_template, :fields

      def initialize(title, description, server_template, id=nil, default_view_url=nil, web_full_url=nil)
        @title = title
        @description = description
        @server_template = server_template
        @id = id
        @default_view_url = default_view_url
        @web_full_url = web_full_url
        @shallow = true
        @fields = {}

        # Create a new object in Sharepoint if the id is nil
        sp_add_list! if @id.nil?

        # Add the Sharepoint Fields associated with this list
        add_fields!
      end

      def add_item(title)
        method = {
          '0,TestID' => {:Cmd => 'New', :fields => {:Title => title}} }
        SPWS.instance.list_ws.update_list_items(self, method)
      end

      def items
        SPWS.instance.list_ws.get_list_items(self)
      end

      def delete!
        SPWS.instance.list_ws.delete_list(@title)
      end

      def reg_field(f_name, f_type)
        @fields[f_name.to_sym] = f_type
      end


      private

      # This is a new list.  Add it to Sharepoint
      def sp_add_list!
        list = SPWS.instance.list_ws.add_list(@title, @description, @server_template)
        @id = list[:id]
        @default_view_url = list[:default_view]
        @web_full_url = list[:web_full_url]
      end

      def add_fields!
        SPWS.instance.list_ws.get_list(@id, self)
      end

    end # SPList
  end # SPWS
end # Viewpoint
