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

# This class represents a Sharepoint ListItem returned from the Lists Web Service
# @see 
class Viewpoint::SPWS::Types::ListItem
  include Viewpoint::SPWS::Types

  attr_reader :id, :body, :file_name, :file_ref, :editor, :guid, :object_type
  attr_reader :created_date, :modified_date, :due_date
  attr_reader :title, :link_title, :status, :priority, :percent_complete

  # @param [Viewpoint::SPWS::Websvc::List] ws The webservice instance this ListItem spawned from
  # @param [String] list_id The list id that this item belongs to
  # @param [Nokogiri::XML::Element] xml the List element we are building from
  def initialize(ws, list_id, xml)
    @ws = ws
    @list_id = list_id
    @pending_updates = []
    parse_xml_fields(xml)
  end

  # Save any pending changes
  def save!
    @ws.update_list_items(@list_id, :item_updates => @pending_updates)
    # @todo check for success before emptying Arry
    @pending_updates = []
  end

  # Delete this ListItem
  def delete!
    del = [{ :id => @id, :command => 'Delete',
      :file_ref => full_file_ref }]
    @ws.update_list_items(@list_id, :item_updates => del)
  end

  # Set a new title for this Item
  # @param [String] title The new title
  # @return [String] The new title of the ListItem if the call is successful
  def rename!(title)
    upd = [{ :id => @id, :command => 'Update',
      :title => title,
    }]
    resp = @ws.update_list_items(@list_id, :item_updates => upd)
    @title = resp[:update].first['ows_Title']
  end

  # Set the priority of this Item
  # @param [Symbol] priority The new priority. It must be one of these values:
  #   :high, :normal, :low
  # @return [String] The new priority of the ListItem if the call is successful
  def set_priority!(priority)
    raise "Invalid priority it must be one of: #{PRIORITY.keys.join(', ')}" unless PRIORITY[priority]
    upd = [{ :id => @id, :command => 'Update',
      :priority => PRIORITY[priority],
    }]
    resp = @ws.update_list_items(@list_id, :item_updates => upd)
    @priority = resp[:update].first['ows_Priority']
  end

  # Set the status of this Item
  # @param [Symbol] status The new status. It must be one of these values:
  #   :not_started, :in_progress, :completed, :deferred, :waiting
  # @return [String] The new status of the ListItem if the call is successful
  def set_status!(status)
    raise "Invalid status it must be one of: #{STATUS.keys.join(', ')}" unless STATUS[status]
    upd = [{ :id => @id, :command => 'Update',
      :status => STATUS[status],
    }]
    resp = @ws.update_list_items(@list_id, :item_updates => upd)
    @status = resp[:update].first['ows_Status']
  end

  # Set the percentage complete of this item.
  # @param [Fixnum] pct the percent complete of this item
  # @return [Fixnum] The new percent complete of the ListItem if the call is
  #   successful
  def set_percent_complete!(pct)
    if(!(0..100).include?(pct))
      raise "Invalid :percent_complete #{topts[:percent_complete]}"
    end
    upd = { :id => @id, :command => 'Update',
      :percent_complete => pct,
    }
    resp = @ws.update_list_items(@list_id, :item_updates => [upd])
    @percent_complete = resp[:update].first['ows_PercentComplete']
  end

  # Assign this item to a user
  # @param [Viewpoint::SPWS::Types::User] user The user to assign this ListItem
  # @todo should I return the String representation of the user or the Types::User?
  def assign!(user)
    upd = [{ :id => @id, :command => 'Update',
      :AssignedTo => "#{user.id};##{user.login_name}",
    }]

    resp = @ws.update_list_items(@list_id, :item_updates => upd)
    @assigned_to = resp[:update].first['ows_AssignedTo']
  end

  private

  # Return the full FileRef with the site URL attatched
  def full_file_ref
    uri =  @ws.spcon.site_base
    url = "#{uri.scheme}://#{uri.host}"
    url << ":#{uri.port}" unless (uri.port == 80 || uri.port == 443)
    url << "/#{@file_ref}"
  end

  # Parse the fields out of the passed XML document.
  # @param[Nokogiri::XML::Element] xml
  def parse_xml_fields(xml)
    @xmldoc = xml
    set_field   :@id, 'ows_ID'
    set_field   :@file_name, 'ows_LinkFilename'
    set_field   :@meta_info, 'ows_MetaInfo'
    set_field   :@link_title, 'ows_LinkTitle'
    set_field   :@body, 'ows_Body'
    set_field   :@title, 'ows_Title'
    set_field   :@status, 'ows_Status'
    set_field   :@priority, 'ows_Priority'
    set_field   :@percent_complete, 'ows_PercentComplete'
    set_field   :@due_date, 'ows_DueDate'
    set_field   :@assigned_to, 'ows_AssignedTo'
    set_field   :@file_ref, 'ows_FileRef'
    set_field   :@editor, 'ows_Editor'
    set_field   :@guid, 'ows_UniqueId'
    set_field   :@object_type, 'ows_FSObjType'
    set_field   :@created_date, 'ows_Created'
    set_field   :@modified_date, 'ows_Modified'
    set_field   :@created_date, 'ows_Created_x0020_Date' unless @created_date
    set_field   :@modified_date, 'ows_Last_x0020_Modified' unless @modified_date
    @xmldoc = nil
  end

  # Parse a Sharepoint field or managed field
  # @param [Symbol] vname The instance variable we will set the value to if it exists
  # @param [String] fname The field name to check for
  def set_field(vname, fname)
    newvar = nil
    field = @xmldoc[fname]
    if field
      if(field =~ /;#/)
        newvar = @xmldoc[fname].split(';#').last
      else
        newvar = field
      end
      newvar = transform(newvar)
    end
    instance_variable_set vname, newvar
  end

  # Run misc transforms on data
  def transform(newvar)
    case newvar
    when /[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}/ # Transform DateTime
      return DateTime.parse(newvar)
    else
      return newvar
    end
  end
end
