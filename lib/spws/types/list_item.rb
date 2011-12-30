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
    @file_name  = xml['ows_LinkFilename']
    @file_ref   = get_mfield(xml['ows_FileRef'])
    @editor     = get_mfield(xml['ows_Editor'])
    @guid       = get_mfield(xml['ows_UniqueId'])
    @object_type    = get_mfield(xml['ows_FSObjType'])
    @created_date   = DateTime.parse(get_mfield(xml['ows_Created_x0020_Date']))
    @modified_date  = DateTime.parse(get_mfield(xml['ows_Last_x0020_Modified']))
    @meta_info  = xml['ows_MetaInfo']
    #@xmldoc = xml
  end


  private

  # Parse a Sharepoint managed field
  def get_mfield(name)
    name.split(';#').last
  end
end
