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
# @see http://msdn.microsoft.com/en-us/library/ms434081(v=office.12).aspx
class Viewpoint::SPWS::List

  attr_reader :guid, :title, :description, :created, :modified

  # @param [Nokogiri::XML::Element] xml the List element we are building from
  def initialize(xml)
    @guid   = xml['ID']
    @title  = xml['Title']
    @description = xml['Description']
    @hidden = (xml['Hidden'] == 'True')
    @created = xml['Created']
    @modified = xml['Modified']
    @item_count = xml['ItemCount']
    #@xmldoc = xml
  end

  def hidden?
    @hidden
  end
end
