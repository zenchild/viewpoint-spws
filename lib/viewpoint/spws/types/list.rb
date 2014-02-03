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

# This class represents a Sharepoint List returned from the Lists Web Service
# @see http://msdn.microsoft.com/en-us/library/ms774810(v=office.12).aspx
class Viewpoint::SPWS::Types::List
  include Viewpoint::SPWS::Types

  attr_reader :guid, :title, :description, :created, :modified, :server_template,
    :feature_id, :root_folder

  # @param [Viewpoint::SPWS::Websvc::List] ws The webservice instance this List spawned from
  # @param [Nokogiri::XML::Element] xml the List element we are building from
  def initialize(ws, xml)
    @ws             = ws
    @guid           = xml['ID']
    @title          = xml['Title']
    @description    = xml['Description']
    @hidden         = (xml['Hidden'] == 'True')
    @created        = @ws.parse_time(xml['Created'])
    @modified       = @ws.parse_time(xml['Modified'])
    @last_deleted   = @ws.parse_time(xml['LastDeleted'])
    @item_count     = xml['ItemCount']
    @server_template= xml['ServerTemplate'].to_i
    @feature_id     = xml['FeatureId']
    @root_folder    = xml['RootFolder']
    #@xmldoc         = xml
    @list_path      = nil
  end

  # Return the full-qualified path of this List
  def path
    return @list_path if @list_path
    site = @ws.spcon.site_base
    @list_path = "#{site.scheme}://#{site.host}"
    @list_path << ":#{site.port}" unless(site.port == 80 || site.port == 443)
    @list_path << @root_folder
  end

  # Add a ListItem
  # @param [Hash] opts options for List creation.
  def add_item!(opts)
    op = { :command => 'New', :id => 'New' }
    opts.keys.each do |k|
      case k
      when :priority
        op[k] = PRIORITY[opts[:priority]]
      when :status
        op[k] = STATUS[opts[:status]]
      when :percent_complete
        op[k] = opts[k] * 0.01
      else
        op[k] = opts[k]
      end
    end

    resp = @ws.update_list_items(@guid, :item_updates => [op])
    resp[:new].first
  end

  # Delete this List
  def delete!
    @ws.delete_list(@guid)
  end

  # Return the items in this List
  def items
    @ws.get_list_items(@guid)
  end

  # @param [String] item_id The item id for the item you want to retrieve
  def get_item(item_id)
    addl_fields = %w{LinkTitle Body AssignedTo Status Priority DueDate PercentComplete}

    i = @ws.get_list_items(@guid, :recursive => true, :view_fields => addl_fields) do |b|
      b.Query {
        b.Where {
          b.Eq {
            b.FieldRef(:Name => 'ID')
            b.Value(item_id, :Type => 'Counter')
          }
        }
      }
    end
    raise "Returned more than one item for #get_item" if(i.length > 1)
    i.first
  end

  def hidden?
    @hidden
  end
end
