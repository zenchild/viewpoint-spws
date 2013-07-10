# -*- coding: utf-8 -*-
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

# This class represents a Sharepoint Version returned from the Lists Web Service
# @see http://msdn.microsoft.com/en-us/library/ms774810(v=office.12).aspx
class Viewpoint::SPWS::Types::Version
  include Viewpoint::SPWS::Types

  attr_reader :version, :url, :created, :created_by, :size, :comments

  # @param [Viewpoint::SPWS::Websvc::Versions] ws The webservice instance this Result spawned from
  # @param [Nokogiri::XML::Element] xml the List element we are building from
  def initialize(ws, xml)
    @ws             = ws
    @version        = xml['version']
    @url            = xml['url']
    @created        = DateTime.parse(xml['createdRaw'])
    @created_by     = xml['createdBy']
    @size           = xml['size']
    @comments       = xml['comments']
  end
end
