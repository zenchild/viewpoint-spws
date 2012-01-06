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

# This class represents a Sharepoint User Item returned from the UserGroup Web Service
class Viewpoint::SPWS::User

  attr_reader :id, :sid, :name, :login_name, :email, :notes, :flags

  # @param [Viewpoint::SPWS::UserGroup] ws The webservice instance this user spawned from
  # @param [Nokogiri::XML::Element] xml the List element we are building from
  def initialize(ws, xml)
    @ws = ws
    parse_xml_fields(xml)
  end

  def is_site_admin?
    @is_site_admin
  end

  def is_domain_group?
    @is_domain_group
  end

  def site_user?
    @site_user
  end

  private

  # Parse the fields out of the passed XML document.
  # @param[Nokogiri::XML::Element] xml
  def parse_xml_fields(xml)
    @xmldoc = xml
    set_field   :@id, 'ID'
    set_field   :@sid, 'Sid'
    set_field   :@name, 'Name'
    set_field   :@login_name, 'LoginName'
    set_field   :@email, 'Email'
    set_field   :@notes, 'Notes'
    set_field   :@is_site_admin, 'IsSiteAdmin', 'Boolean'
    set_field   :@is_domain_group, 'IsDomainGroup', 'Boolean'
    set_field   :@flags, 'Flags'
    @site_user  = (xml['SiteUser'] == 1)
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
  # @param [String] type ('String') optional type for additional processing
  def set_field(vname, fname, type = 'String')
    case type
    when 'Boolean'
      val = (@xmldoc[fname] =~ /True/i) ? true : false
      instance_variable_set vname, val
    else
      instance_variable_set vname, @xmldoc[fname] if @xmldoc[fname]
    end
  end

end

