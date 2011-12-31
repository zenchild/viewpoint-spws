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
class Viewpoint::SPWS::ListItem

  attr_reader :file_name, :file_ref, :editor, :guid, :object_type
  attr_reader :created_date, :modified_date

  # @param [Nokogiri::XML::Element] xml the List element we are building from
  def initialize(xml)
    parse_xml_fields(xml)
  end


  private


  # Parse the fields out of the passed XML document.
  # @param[Nokogiri::XML::Element] xml
  def parse_xml_fields(xml)
    @xmldoc = xml
    set_field   :@file_name, 'ows_LinkFilename'
    set_field   :@meta_info, 'ows_MetaInfo'
    set_field   :@link_title, 'ows_LinkTitle'
    set_field   :@title, 'ows_Title'
    set_field   :@status, 'ows_Status'
    set_field   :@priority, 'ows_Priority'
    set_field   :@percent_complete, 'ows_PercentComplete'
    set_field   :@due_date, 'ows_DueDate'
    #if(defined? @due_date && @due_date)
    #  @due_date = DateTime.parse(@due_date)
    #end
    set_mfield  :@assigned_to, 'ows_AssignedTo'
    set_mfield  :@file_ref, 'ows_FileRef'
    set_mfield  :@editor, 'ows_Editor'
    set_mfield  :@guid, 'ows_UniqueId'
    set_mfield  :@object_type, 'ows_FSObjType'
    set_mfield  :@created_date, 'ows_Created_x0020_Date'
    #if(defined? @created_date && @created_date)
    #  @created_date = DateTime.parse(@created_date)
    #end
    set_mfield  :@modified_date, 'ows_Last_x0020_Modified'
    #if(defined? @modified_date && @modified_date)
    #  @modified_date = DateTime.parse(@modified_date)
    #end

    @xmldoc = nil
  end


  # Parse a Sharepoint managed field
  # @param [Symbol] vname The instance variable we will set the value to if it exists
  # @param [String] fname The field name to check for
  def set_mfield(vname, fname)
    instance_variable_set vname, @xmldoc[fname].split(';#').last if @xmldoc[fname]
  end

  # @param [Symbol] vname The instance variable we will set the value to if it exists
  # @param [String] fname The field name to check for
  def set_field(vname, fname)
    instance_variable_set vname, @xmldoc[fname] if @xmldoc[fname]
  end
end
