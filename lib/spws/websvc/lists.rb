=begin
  This file is part of ViewpointSPWS; the Ruby library for Microsoft Sharepoint Web Services.

  Copyright © 2011 Dan Wanek <dan.wanek@gmail.com>

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
=end

# This class represents the Sharepoint Lists Web Service.
# @see http://msdn.microsoft.com/en-us/library/ms774654(v=office.12).aspx
class Viewpoint::SPWS::Lists
  include Viewpoint::SPWS::WebServiceBase

  def initialize(spcon)
    @default_ns  = 'http://schemas.microsoft.com/sharepoint/soap/'
    @ws_endpoint = '_vti_bin/Lists.asmx'
    super
  end

  # Returns all the lists for a Sharepoint site.
  # @param [Boolean] show_hidden Whether or not to show hidden lists. Default = false
  # @see http://msdn.microsoft.com/en-us/library/lists.lists.getlistcollection(v=office.12).aspx
  def get_list_collection(show_hidden = false)
    soapmsg = build_soap_envelope do |type, builder|
      if(type == :header)
      else
        builder.GetListCollection {
          builder.parent.default_namespace = @default_ns
        }
      end
    end
    soaprsp = Nokogiri::XML(send_soap_request(soapmsg.doc.to_xml))
    ns = {"xmlns"=> @default_ns}
    lists = []
    soaprsp.xpath('//xmlns:Lists/xmlns:List', ns).each do |l|
      lists << List.new(l)
    end
    if(!show_hidden)
      lists.reject! do |i|
        i.hidden?
      end
    end
    lists
  end
  alias :get_lists :get_list_collection


  # Retrieve a specific Sharepoint List
  # @see http://msdn.microsoft.com/en-us/library/lists.lists.getlist(v=office.12).aspx
  # @param [String] list title or the GUID for the list
  # @return [Viewpoint::SPWS::List]
  def get_list(list)
    soapmsg = build_soap_envelope do |type, builder|
      if(type == :header)
      else
        builder.GetList {
          builder.parent.default_namespace = @default_ns
          builder.listName(list)
        }
      end
    end
    soaprsp = Nokogiri::XML(send_soap_request(soapmsg.doc.to_xml))
    ns = {"xmlns"=> @default_ns}
    List.new(soaprsp.xpath('//xmlns:GetListResult/xmlns:List', ns).first)
  end

  # Get List Items based on certain parameters
  # @see http://msdn.microsoft.com/en-us/library/lists.lists.getlistitems(v=office.12).aspx
  # @param [String] list title or the GUID for the list
  # @param [Hash] opts
  # @option opts [String] :view_name ('') GUID for the view surrounded by curly braces 
  #   If nothing is passed it used the default of the View
  # @option opts [String] :row_limit ('') A String representing the number of rows to return.
  # @option opts [Boolean] :recursive (true) If true look in subfolders as well as root
  # @option opts [Boolean] :date_in_utc (true) If true return dates in UTC
  # @option opts [String]  :folder ('') 
  #   Filter document library items for items in the specified folder
  # @yield [builder] Yields a Builder object that can be used to build a CAML Query. See the
  #   example below on how to use it.
  # @yieldparam [Nokogiro::XML::Builder] builder The builder object used to create the Query
  # @example The following example shows how to prepare a CAML Query with a block. It
  #   filters for all objects of ObjectType '0' = Files
  #   items = listws.get_list_items('Shared Documents',:recursive => true) do |b|
  #     b.Query {
  #       b.Where {
  #         b.Eq {
  #           b.FieldRef(:Name => 'FSObjType')
  #           b.Value(0, :Type => 'Integer')
  #         }
  #       }
  #     }
  #   end
  def get_list_items(list, opts = {})
    # Set Default values
    opts[:recursive] = true unless opts.has_key?(:recursive)
    opts[:view_name] = '' unless opts.has_key?(:view_name)
    opts[:row_limit] = '' unless opts.has_key?(:row_limit)
    opts[:date_in_utc] = true unless opts.has_key?(:date_in_utc)
    opts[:folder] = '' unless opts.has_key?(:folder)

    soapmsg = build_soap_envelope do |type, builder|
      if(type == :header)
      else
        builder.GetListItems {
          builder.parent.default_namespace = @default_ns
          builder.listName(list)
          builder.viewName(opts[:view_name])
          builder.rowLimit(opts[:row_limit])

          if block_given?
            builder.query {
              builder.parent.default_namespace = ''
              yield builder
            }
          end

          builder.queryOptions {
            builder.QueryOptions {
              builder.parent.default_namespace = ''
              builder.Folder(opts[:folder])
              builder.ViewAttributes(:Scope => 'Recursive') if opts[:recursive]
              builder.DateInUtc('True') if opts[:date_in_utc]
            }
          }
          # @todo Is this worth supporting???
          #builder.webID(parms[:web_id])
        }
      end
    end
    soaprsp = Nokogiri::XML(send_soap_request(soapmsg.doc.to_xml))
    ns = {"xmlns"=> @default_ns}
    ns = {'xmlns:z' => "#RowsetSchema"}
    items = []
    soaprsp.xpath('//z:row', ns).each do |li|
      items << ListItem.new(li)
    end
    items
  end
end
