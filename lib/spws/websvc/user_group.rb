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

# This class represents the Sharepoint User and Groups Web Service.
# @see http://msdn.microsoft.com/en-us/library/ms772647(v=office.12).aspx
class Viewpoint::SPWS::UserGroup
  include Viewpoint::SPWS::WebServiceBase

  def initialize(spcon)
    @default_ns = 'http://schemas.microsoft.com/sharepoint/soap/directory/'
    @ws_endpoint = '_vti_bin/UserGroup.asmx'
    super
  end

  # Returns information about a specified user
  # @param [String] user A username to retrieve infor for. It must be of the form
  #   DOMAIN\username
  def get_user_info(user)
    soapmsg = build_soap_envelope do |type, builder|
      if(type == :header)
      else
        builder.GetUserInfo {
          builder.parent.default_namespace = @default_ns
          builder.userLoginName(user)
        }
      end
    end
    send_soap_request(soapmsg.doc.to_xml)
    #soaprsp = Nokogiri::XML(send_soap_request(soapmsg.doc.to_xml))
  end

  # Get user logins from e-mail addresses
  # @param [Array<String>] emails an Array of e-mail addresses to search for
  def get_user_login_from_email(emails)
    soapmsg = build_soap_envelope do |type, builder|
      if(type == :header)
      else
        builder.GetUserLoginFromEmail {
          builder.parent.default_namespace = @default_ns
          builder.emailXml {
            builder.Users {
              emails.each do |email|
                builder.User(:Email => email)
              end
            }
          }
        }
      end

      ns = {"xmlns"=> @default_ns}
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
    soaprsp = Nokogiri::XML(send_soap_request(soapmsg.doc.to_xml))
  end

end
