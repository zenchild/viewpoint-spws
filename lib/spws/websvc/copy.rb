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

# This class represents the Sharepoint Copy Web Service.
# @see http://msdn.microsoft.com/en-us/library/copy(v=office.12).aspx
class Viewpoint::SPWS::Copy
  include Viewpoint::SPWS::WebServiceBase

  def initialize(spcon)
    @default_ns  = 'http://schemas.microsoft.com/sharepoint/soap/'
    @ws_endpoint = '_vti_bin/Copy.asmx'
    super
  end

  # Copies a document represented by a Byte array to one or more locations on a server.
  # @see http://msdn.microsoft.com/en-us/library/copy.copy.copyintoitems(v=office.12).aspx
  # @param [String] srcfile Either a relative or absolute path to the input file
  # @param [Array<String>] tgturls An array of absolute URLs to copy the source to.
  # @todo parse the return and check for errors
  def copy_into_items(srcfile, tgturls)
    soapmsg = build_soap_envelope do |type, builder|
      if(type == :header)
      else
        builder.CopyIntoItems {
          builder.parent.default_namespace = @default_ns
          builder.SourceUrl(srcfile)
          builder.DestinationUrls {
            tgturls.each {|tgt| builder.string(tgt) }
          }
          builder.Fields
          builder.Stream(Base64.encode64(File.read(srcfile)))
        }
      end
    end

    soaprsp = Nokogiri::XML(send_soap_request(soapmsg.doc.to_xml))
  end

  # Copies a document from one location on a server running Windows SharePoint Services
  #   to another location on the same server.
  # @see http://msdn.microsoft.com/en-us/library/copy.copy.copyintoitemslocal(v=office.12).aspx
  # @param [String] srcurl An absolute URL to the document you want to copy from.
  # @param [Array<String>] tgturls An array of absolute URLs to copy the source to.
  # @todo parse the return and check for errors
  def copy_into_items_local(srcurl, tgturls)
    soapmsg = build_soap_envelope do |type, builder|
      if(type == :header)
      else
        builder.CopyIntoItemsLocal {
          builder.parent.default_namespace = @default_ns
          builder.SourceUrl(srcurl)
          builder.DestinationUrls {
            tgturls.each {|tgt| builder.string(tgt) }
          }
        }
      end
    end

    soaprsp = Nokogiri::XML(send_soap_request(soapmsg.doc.to_xml))
  end

  # Generates a Byte array representation of a document
  # @see http://msdn.microsoft.com/en-us/library/copy.copy.getitem(v=office.12).aspx
  # @param [String] tgturl An absolute URL to the document you want to retrieve the
  #   byte stream for.
  # @return [Hash] it returns a Hash with the keys :stream that has the Base64 encoded
  #   file data and a key :fields which is an Array of Hash data that contains document
  #   metadata.
  def get_item(tgturl)
    soapmsg = build_soap_envelope do |type, builder|
      if(type == :header)
      else
        builder.GetItem {
          builder.parent.default_namespace = @default_ns
          builder.Url(tgturl)
        }
      end
    end

    soaprsp = Nokogiri::XML(send_soap_request(soapmsg.doc.to_xml))
    ns = {"xmlns"=> @default_ns}
    data = {}
    data[:stream] = soaprsp.xpath('//xmlns:GetItemResponse/xmlns:Stream',ns).first.content
    fields = []
    soaprsp.xpath('//xmlns:GetItemResponse/xmlns:Fields/xmlns:FieldInformation',ns).each do |f|
      fields << {:type => f['Type'], :display_name => f['DisplayName'],
        :id => f['Id'], :value => f['Value']}
    end
    data[:fields] = fields
    data
  end

end
