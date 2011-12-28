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

# This class represents the Sharepoint Lists Web Service.
# @see http://msdn.microsoft.com/en-us/library/ms774654.aspx
class Viewpoint::SPWS::Lists
  include Viewpoint::SPWS

  NAMESPACES = {
    'xmlns:soap'  => 'http://schemas.xmlsoap.org/soap/envelope/',
    'xmlns:xsi'   => 'http://www.w3.org/2001/XMLSchema-instance',
    'xmlns:xsd'   => 'http://www.w3.org/2001/XMLSchema',
    'xmlns:spws'  => 'http://schemas.microsoft.com/sharepoint/soap/',
  }.freeze

  WS_ENDPOINT = '_vti_bin/Lists.asmx'.freeze

  # @param [Viewpoint::SPWS::Connection] spcon A connection to a Sharepoint Site
  def initialize(spcon)
    @spcon = spcon
    raise "Auth failure" unless(@spcon.authenticate(WS_ENDPOINT))
  end

  # Returns all the lists for a Sharepoint site.
  # @param [Boolean] show_hidden Whether or not to show hidden lists. Default = false
  # @see http://msdn.microsoft.com/en-us/library/lists.lists.getlistcollection(v=office.12).aspx
  def get_list_collection(show_hidden = false)
    soapmsg = build_soap_envelope do |type, builder|
      if(type == :header)
      else
        builder['spws'].GetListCollection
      end
    end
    soaprsp = Nokogiri::XML(send_soap_request(soapmsg.doc.to_xml))
    ns = {"xmlns"=>"http://schemas.microsoft.com/sharepoint/soap/"}
    lists = []
    soaprsp.xpath('//xmlns:Lists/xmlns:List', ns).each do |l|
      lists << List.new(l)
    end
    if(!show_hidden)
      lists.reject! do |i|
        i.hidden?
      end
    end
    lists
  end
  alias :get_lists :get_list_collection


  private

  def build_soap_envelope
    new_ent = Nokogiri::XML::Builder.new do |xml|
      xml.Envelope(NAMESPACES) do |ent|
        xml.parent.namespace = xml.parent.namespace_definitions.find{|ns|ns.prefix=="soap"}
        ent['soap'].Header {
          yield(:header, ent) if block_given?
        }
        ent['soap'].Body {
          yield(:body, ent) if block_given?
        }
      end
    end
  end

  # Send the SOAP request to the endpoint
  # @param [String] soapmsg an XML formatted string
  def send_soap_request(soapmsg)
    @spcon.post(WS_ENDPOINT, soapmsg)
  end

end
