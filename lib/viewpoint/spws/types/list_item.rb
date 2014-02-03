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
    @pending_updates  = [] # a place to store updates before #save! is called
    @update_keys      = {} # the variables to update after #save!
    parse_xml_fields(xml)
  end

  # Save any pending changes
  def save!
    return true if @pending_updates.empty?
    resp = @ws.update_list_items(@list_id, :item_updates => @pending_updates)
    # @todo check for success before emptying Arry
    update_local_vars resp[:update][0]
    @pending_updates.clear
    true
    resp
  end

  # Pass a block of updates that will be committed in one transaction
  # @example
  #   li.update! do |l|
  #     l.rename 'New Name'
  #     l.set_priority :low
  #     l.set_status :waiting
  #   end
  def update!
    yield self if block_given?
    save!
  end

  # Delete this ListItem
  def delete!
    del = [{ :id => @id, :command => 'Delete',
      :file_ref => full_file_ref }]
    @ws.update_list_items(@list_id, :item_updates => del)
  end


  # Set a new title for this Item
  # @param [String] title The new title
  def rename(title)
    raise "There is already a pending rename" if @update_keys[:@title]
    upd = { :id => @id, :command => 'Update',
      :title => title,
    }
    @pending_updates << upd
    @update_keys[:@title]       = 'ows_Title'
    @update_keys[:@link_title]  = 'ows_LinkTitle'
    title
  end

  # Set a new title for this Item
  # @see #rename
  def rename!(title)
    rename(title)
    save!
  end

  # Set the priority of this Item
  # @param [Symbol] priority The new priority. It must be one of these values:
  #   :high, :normal, :low
  def set_priority(priority)
    raise "Invalid priority it must be one of: #{PRIORITY.keys.join(', ')}" unless PRIORITY[priority]
    raise "There is already a pending priority change" if @update_keys[:@priority]
    upd = { :id => @id, :command => 'Update',
      :priority => PRIORITY[priority],
    }
    @pending_updates << upd
    @update_keys[:@priority] = 'ows_Priority'
    priority
  end

  # Set the priority of this Item
  # @see #set_priority
  def set_priority!(priority)
    set_priority priority
    save!
  end

  # Set the status of this Item
  # @param [Symbol] status The new status. It must be one of these values:
  #   :not_started, :in_progress, :completed, :deferred, :waiting
  def set_status(status)
    raise "Invalid status it must be one of: #{STATUS.keys.join(', ')}" unless STATUS[status]
    raise "There is already a pending status change" if @update_keys[:@status]
    upd = { :id => @id, :command => 'Update',
      :status => STATUS[status],
    }
    @pending_updates << upd
    @update_keys[:@status] = 'ows_Status'
    status
  end

  # Set the status of this Item
  # @see #set_status
  def set_status!(status)
    set_status(status)
    save!
  end

  # Set the percentage complete of this item.
  # @param [Fixnum] pct the percent complete of this item
  def set_percent_complete(pct)
    if(!(0..100).include?(pct))
      raise "Invalid :percent_complete #{topts[:percent_complete]}"
    end
    raise "There is already a pending percent complete change" if @update_keys[:@percent_complete]

    upd = { :id => @id, :command => 'Update',
      :percent_complete => pct,
    }
    @pending_updates << upd
    @update_keys[:@percent_complete] = 'ows_PercentComplete'
    pct
  end

  # Set the percentage complete of this item.
  # @see #set_percent_complete
  def set_percent_complete!(pct)
    set_percent_complete pct
    save!
  end

  # Assign this item to a user
  # @param [Viewpoint::SPWS::Types::User] user The user to assign this ListItem
  # @todo should I return the String representation of the user or the Types::User?
  def assign(user)
    raise "There is already a pending assignment" if @update_keys[:@assigned_to]
    upd = { :id => @id, :command => 'Update',
      :AssignedTo => "#{user.id};##{user.login_name}",
    }
    @pending_updates << upd
    @update_keys[:@assigned_to] = 'ows_AssignedTo'
    user
  end

  # Assign this item to a user
  # @see #assign
  def assign!(user)
    assign(user)
    save!
  end

  private

  # Return the full FileRef with the site URL attatched
  def full_file_ref
    uri =  @ws.spcon.site_base
    url = "#{uri.scheme}://#{uri.host}"
    url << ":#{uri.port}" unless (uri.port == 80 || uri.port == 443)
    url << "/#{@file_ref}"
  end

  # update the local variables after a #save!.
  # Changed variables are tracked in @update_keys
  # @param [Hash] resp The response Hash from a #save!
  def update_local_vars(resp)
    @update_keys.each_pair do |k,v|
      set_field k, v, resp
    end
    @update_keys.clear
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
  # @param [#[]] mapsrc A dictionary or Hash like item that contains variable data.
  def set_field(vname, fname, mapsrc = @xmldoc)
    newvar = nil
    field = mapsrc[fname]
    if field
      if(field =~ /;#/)
        newvar = mapsrc[fname].split(';#').last
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
      return @ws.parse_time(newvar)
    else
      return newvar
    end
  end
end
