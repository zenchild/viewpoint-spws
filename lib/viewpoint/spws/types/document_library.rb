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

# This class represents a Sharepoint List returned from the Lists Web Service with a
# ServerTemplate id of 101 (DocumentLibrary).
# @see http://msdn.microsoft.com/en-us/library/ms774810(v=office.12).aspx
class Viewpoint::SPWS::Types::DocumentLibrary < Viewpoint::SPWS::Types::List
  include Viewpoint::SPWS::Types

  # @param [Viewpoint::SPWS::Websvc::List] ws The webservice instance this List spawned from
  # @param [Nokogiri::XML::Element] xml the List element we are building from
  def initialize(ws, xml)
    @copy_ws = Viewpoint::SPWS::Websvc::Copy.new(ws.spcon)
    super
  end

  # Add a Document to this List
  # @param [Hash] opts parameters for this Document
  # @option opts [String] :file Path to the file to upload
  # @return [Viewpoint::SPWS::Types::ListItem] The newly added Task
  def add_file!(opts)
    raise "Valid file argument required" unless(opts[:file] && File.exists?(opts[:file]))
    fqpath = "#{self.path}/#{File.basename(opts[:file])}"
    @copy_ws.copy_into_items(opts[:file], [fqpath])
  end
end
