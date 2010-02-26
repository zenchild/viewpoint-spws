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
    class ListParser
      def initialize(response)
        # Unwrap SOAP Envelope
        @response = (response/'//soap:Body/*').first
        @response_type = @response.native_element.name
      end

      def parse(opts)
        resp_method = ruby_case(@response_type)
        if(method_exists?(resp_method))
          method(resp_method).call(opts)
        else
          @response
        end
      end
      
      # Parsing Methods
      # ---------------

      def add_list_response(opts)
        l = (@response/'//tns:List').first
        return {:id => l['ID'], :title => l['Title'],
          :description => l['Description'],
          :template => l['ServerTemplate'],
          :default_view => l['DefaultViewUrl'],
          :web_full_url => l['WebFullUrl'] }
      end

      def get_attachment_collection_response(opts)
        urls = []
        (@response/'//tns:Attachment').each do |a|
          urls << a.to_s
        end
        urls
      end

      def get_list_response(opts)
        l = (@response/'//tns:List').first
        if(opts[:list])
          list = opts[:list]
          list.id = l['ID']
          list.default_view_url = l['DefaultViewUrl']
          list.web_full_url = ['WebFullUrl']
        else
          list = SPList.new(l['Title'], l['Description'], l['ServerTemplate'], l['ID'], l['DefaultViewUrl'], l['WebFullUrl'])
        end
        
        (@response/'//tns:Field').each do |f|
          unless( f['Hidden'] == 'TRUE' ||  f['Group'] == '_Hidden' || f['ReadOnly'] == 'TRUE' || f['Type'] == nil)
            list.reg_field(f['Name'], f['Type'])
          end
        end

        list
      end

      def get_list_collection_response(opts)
        lists = []
        (@response/'//tns:List').each do |l|
          lists << SPList.new(l['Title'], l['Description'], l['ServerTemplate'], l['ID'], l['DefaultViewUrl'], l['WebFullUrl'])
        end
        lists
      end

      def get_list_items_response(opts)
        items = []
        (@response/'//z:row').each do |r|
          items << SPListItem.new(opts[:list],r['ows_ID'],r['ows_Title'])
        end
        items
      end

      def update_list_items_response(opts)
        #results = {}
        (@response/'//tns:Result').each do |r|
          #results[r['ID']] = (r/'//tns:ErrorCode').first.to_s
          return false if (r/'//tns:ErrorCode').first.to_s != '0x00000000'
        end
        true
      end


      private

      # CamelCase to ruby_case
      # This is used to turn the response message into the correct ruby method for parsing
      def ruby_case(string)
        string.split(/(?=[A-Z])/).join('_').downcase
      end
      
      def method_exists?(method_name)
        return self.methods.include?(method_name)
      end

    end # ListParser
  end # Sharepoint
end # Viewpoint
