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

  attr_reader :id, :body, :file_name, :file_ref, :editor, :guid, :object_type
  attr_reader :created_date, :modified_date, :due_date
  attr_reader :title, :link_title, :status, :priority, :percent_complete

  # @param [Viewpoint::SPWS::Websvc::List] ws The webservice instance this ListItem spawned from
  # @param [String] list_id The list id that this item belongs to
  # @param [Nokogiri::XML::Element] xml the List element we are building from
  def initialize(ws, list_id, xml)
    @ws = ws
    @list_id = list_id
    parse_xml_fields(xml)
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
    set_mfield  :@assigned_to, 'ows_AssignedTo'
    set_mfield  :@file_ref, 'ows_FileRef'
    set_mfield  :@editor, 'ows_Editor'
    set_mfield  :@guid, 'ows_UniqueId'
    set_mfield  :@object_type, 'ows_FSObjType'
    set_field   :@created_date, 'ows_Created'
    set_field   :@modified_date, 'ows_Modified'
    set_mfield  :@created_date, 'ows_Created_x0020_Date' unless @created_date
    set_mfield  :@modified_date, 'ows_Last_x0020_Modified' unless @modified_date
    @xmldoc = nil
  end

  # Parse a Sharepoint managed field
  # @param [Symbol] vname The instance variable we will set the value to if it exists
  # @param [String] fname The field name to check for
  def set_mfield(vname, fname)
    newvar = nil
    if @xmldoc[fname]
      newvar = @xmldoc[fname].split(';#').last
      newvar = transform(newvar)
    end
    instance_variable_set vname, newvar
  end

  # @param [Symbol] vname The instance variable we will set the value to if it exists
  # @param [String] fname The field name to check for
  def set_field(vname, fname)
    newvar = nil
    if @xmldoc[fname]
      newvar = @xmldoc[fname]
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
