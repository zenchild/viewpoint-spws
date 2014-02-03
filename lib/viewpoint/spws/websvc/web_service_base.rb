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

# This module represents the common elements of Sharepoint Web Services
module Viewpoint::SPWS::Websvc
  module WebServiceBase
    include Viewpoint::SPWS

    NAMESPACES = {
      'xmlns:soap'  => 'http://www.w3.org/2003/05/soap-envelope',
      'xmlns:xsi'   => 'http://www.w3.org/2001/XMLSchema-instance',
      'xmlns:xsd'   => 'http://www.w3.org/2001/XMLSchema',
    }.freeze

    attr_reader :spcon

    # @param [Viewpoint::SPWS::Connection] spcon A connection to a Sharepoint Site
    # @param [TZInfo::Timezone] server_tz Server timezone of Sharepoint WFE
    def initialize(spcon, server_tz = nil)
      @server_timezone = server_tz
      @log = Logging.logger[self.class.name.to_s.to_sym]
      @spcon = spcon
      raise "Auth failure" unless(@spcon.authenticate(@ws_endpoint))
    end

    def server_timezone
      spcon.server_timezone
    end

    def parse_time(str)
      datetime = DateTime.parse(str)
      datetime = server_timezone.local_to_utc(datetime) if server_timezone
      datetime
    end

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
      @log.debug "Sending SOAP Request:\n----------------\n#{soapmsg}\n----------------"
      respmsg = @spcon.post(@ws_endpoint, soapmsg)
      @log.debug "Received SOAP Response:\n----------------\n#{Nokogiri::XML(respmsg).to_xml}\n----------------"
      respmsg
    end

  end
end
