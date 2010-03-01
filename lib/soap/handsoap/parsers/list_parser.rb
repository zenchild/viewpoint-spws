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
    module SOAP
      class ListParser
        include Parser

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
          (@response/'//tns:Attachment').each do |attachment|
            urls << attachment.to_s
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

          (@response/'//tns:Field').each do |field|
            unless( field['Hidden'] == 'TRUE' ||  field['Group'] == '_Hidden' || field['ReadOnly'] == 'TRUE' || field['Type'] == nil)
              list.reg_field(field['Name'], field['Type'])
            end
          end

          list
        end

        def get_list_collection_response(opts)
          lists = []
          (@response/'//tns:List').each do |list|
            lists << SPList.new(list['Title'], list['Description'], list['ServerTemplate'], list['ID'], list['DefaultViewUrl'], list['WebFullUrl'])
          end
          lists
        end

        def get_list_items_response(opts)
          items = []
          (@response/'//z:row').each do |row|
            nitem = SPListItem.new(opts[:list],row['ows_ID'],row['ows_Title'])
            row.native_element.attributes.each_pair do |k,v|
              nitem.fields[k.sub(/^ows_/,'')] = v.value
            end
            items << nitem
          end
          items
        end

        def update_list_items_response(opts)
          #results = {}
          (@response/'//tns:Result').each do |result|
            #results[result['ID']] = (result/'//tns:ErrorCode').first.to_s
            return false if (result/'//tns:ErrorCode').first.to_s != '0x00000000'
          end
          true
        end

      end # ListParser
    end # SOAP
  end # SPWS
end # Viewpoint
