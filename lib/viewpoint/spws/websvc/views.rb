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
# @see http://msdn.microsoft.com/en-us/library/ms774654(v=office.12).aspx
class Viewpoint::SPWS::Websvc::Views
  include Viewpoint::SPWS::Websvc::WebServiceBase

  def initialize(spcon)
    @default_ns  = 'http://schemas.microsoft.com/sharepoint/soap/'
    @ws_endpoint = '_vti_bin/Views.asmx'
    super
  end

  def get_view_collection(listName)
    soapmsg = build_soap_envelope do |type, builder|
      if(type == :header)
      else
        builder.GetViewCollection {
          builder.parent.default_namespace = @default_ns
          builder.listName(listName)
        }
      end
    end
    soaprsp = Nokogiri::XML(send_soap_request(soapmsg.doc.to_xml))
    ns = {"xmlns"=> @default_ns}
    views = []
    soaprsp.xpath('//xmlns:GetViewCollectionResponse/xmlns:GetViewCollectionResult/xmlns:Views/xmlns:View', ns).each do |l|
      views << Types::View.new(self, l)
    end
    views
  end

  def get_view(listName, viewName)
    soapmsg = build_soap_envelope do |type, builder|
      if(type == :header)
      else
        builder.GetView {
          builder.parent.default_namespace = @default_ns
          builder.listName(listName)
          builder.viewName(viewName)
        }
      end
    end
    soaprsp = Nokogiri::XML(send_soap_request(soapmsg.doc.to_xml))
    ns = {"xmlns"=> @default_ns}
    Types::View.new(self, soaprsp.xpath('//xmlns:GetViewResponse/xmlns:GetViewResult/xmlns:View', ns).first)
  end

end
