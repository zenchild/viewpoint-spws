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

# This class is the glue between the Models and the Web Service.
class Viewpoint::SPWSClient
  include Viewpoint::SPWS

  attr_reader :server_timezone

  # Initialize the SPWSClient instance.
  # @param [String] endpoint The SPWS endpoint we will be connecting to
  # @param [String] user The user to authenticate as. If you are using
  #   NTLM or Negotiate authentication you do not need to pass this parameter.
  # @param [String] pass The user password. If you are using NTLM or
  #   Negotiate authentication you do not need to pass this parameter.
  # @param [Boolean] server_tz Set this to a string representing the
  #   time zone the sharepoint WFE server is set to, e.g. 'Australia/Melbourne'
  def initialize(endpoint, user = nil, pass = nil, server_tz = nil)
    @server_timezone = server_tz ? TZInfo::Timezone.get(server_tz) : nil
    @con = Connection.new(endpoint, @server_timezone)
    @con.set_auth(user,pass) if(user && pass)
  end

  def copy_ws
    @copyws ||= Websvc::Copy.new(@con)
  end

  def lists_ws
    @listsws ||= Websvc::Lists.new(@con)
  end

  def usergroup_ws
    @usergroupws ||= Websvc::UserGroup.new(@con)
  end

  # ========= List Accessor Proxy Methods ========= 

  # Available list types that can be used for #add_list
  LIST_TYPES = {
    :custom_list      => 100,
    :document_library => 101,
    :survey           => 102,
    :links            => 103,
    :announcements    => 104,
    :contacts         => 105,
    :events           => 106,
    :tasks            => 107,
    :discussion_board => 108,
    :picture_library  => 109,
    :datasources      => 110,
    :form_library     => 115,
    :issues           => 1100,
    :custom_list_for_datasheet => 120,
  }

  # Retrieve all of the viewable lists for this site.
  def get_lists
    lists_ws.get_list_collection
  end

  # Retrieve a List object
  # @param [String] list title or the GUID for the list
  def get_list(list)
    lists_ws.get_list(list)
  end

  # Add a List to this site
  # @param [String] name A name for the List
  # @param [String] desc A description of the List
  # @param [Integer] list_type The list template id. Use the LIST_TYPES Hash.
  def add_list(name, desc, list_type)
    lists_ws.add_list(name, desc, list_type)
  end

  # Delete a list from this site.
  # @param [String] list title or the GUID for the list
  def delete_list(list)
    lists_ws.delete_list(list)
  end

  # ========= UserGroup Accessor Proxy Methods ========= 

  # Retrieve a user by e-mail
  # @param [String] user either in e-mail form or DOMAIN\login form. If you
  #   specify an e-mail there is an additional web service call that needs
  #   to be made so if you're worried about performance use the DOMAIN\login
  #   form.
  # @return [Viewpoint::SPWS::Types::User]
  def get_user(user)
    if user =~ /@/
      ulh = usergroup_ws.get_user_login_from_email [user]
      user = ulh[user]
    end
    usergroup_ws.get_user_info user
  end
end
