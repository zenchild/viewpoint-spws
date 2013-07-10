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
class Viewpoint::SPWS::Websvc::UserGroup
  include Viewpoint::SPWS::Websvc::WebServiceBase

  def initialize(spcon)
    @default_ns = 'http://schemas.microsoft.com/sharepoint/soap/directory/'
    @ws_endpoint = '_vti_bin/UserGroup.asmx'
    super
  end

  def get_all_user_collection_from_web
    soapmsg = build_soap_envelope do |type, builder|
      if(type == :header)
      else
        builder.GetAllUserCollectionFromWeb {
          builder.parent.default_namespace = @default_ns
        }
      end
    end
    soaprsp = Nokogiri::XML(send_soap_request(soapmsg.doc.to_xml))
    ns = {'xmlns' => @default_ns}
    users = []
    soaprsp.xpath('//xmlns:Users/xmlns:User', ns).each do |li|
      users << Types::User.new(self,li)
    end
    users
  end

  # Returns information about a specified user
  # @param [String] user A username to retrieve information for. It must be of the form
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
    soaprsp = Nokogiri::XML(send_soap_request(soapmsg.doc.to_xml))
    ns = {'xmlns' => @default_ns}
    user = soaprsp.xpath('//xmlns:GetUserInfo/xmlns:User', ns).first
    Types::User.new(self,user)
  end

  # Get user logins from e-mail addresses
  # @see http://msdn.microsoft.com/en-us/library/ms774890(v=office.12).aspx
  # @param [Array<String>] emails an Array of e-mail addresses to search for
  # @return [Hash] a hash of email to login mappings
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
    end
    soaprsp = Nokogiri::XML(send_soap_request(soapmsg.doc.to_xml))
    ns = {'xmlns' => @default_ns}
    logins = {}
    soaprsp.xpath('//xmlns:GetUserLoginFromEmail/xmlns:User', ns).each do |li|
      logins[li['Email']] = li['Login']
    end
    logins
  end

end
