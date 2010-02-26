#############################################################################
# Copyright © 2010 Dan Wanek <dan.wanek@gmail.com>
#
#
# This file is part of Viewpoint.
# 
# Viewpoint is free software: you can redistribute it and/or
# modify it under the terms of the GNU General Public License as published
# by the Free Software Foundation, either version 3 of the License, or (at
# your option) any later version.
# 
# Viewpoint is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
# Public License for more details.
# 
# You should have received a copy of the GNU General Public License along
# with Viewpoint.  If not, see <http://www.gnu.org/licenses/>.
#############################################################################
$: << File.dirname(__FILE__)
require 'rubygems'
require 'handsoap'
require 'builder'
require 'parser'

Handsoap.http_driver = :http_client

module Viewpoint
  module SPWS
    class UserGroupService < Handsoap::Service
      include ConfigLoader
      
      load_config! # Loads the site config from .viewpointrc (See sp_config.rb) into @@config
      endpoint SPWS_ENDPOINT = {
        :uri => "#{SHAREPOINT_SITE}_vti_bin/usergroup.asmx",
        :version => 1
      }

      SOAP_ACTION_PREFIX='http://schemas.microsoft.com/sharepoint/soap/directory/'

      def initialize()
        @endpoint = SPWS_ENDPOINT[:uri]
        @site = @endpoint.sub(/_vti_bin.*$/,'')
        if $DEBUG
          @debug = File.new('debug.out', 'w')
          @debug.sync = true
        end
      end
      
      # ********** Begin Hooks **********
      def on_create_document(doc)
        doc.alias 'spsoap', 'http://schemas.microsoft.com/sharepoint/soap/directory/'
      end
      
      def on_response_document(doc)
        doc.add_namespace 'soap', 'http://schemas.xmlsoap.org/soap/envelope/'
        doc.add_namespace 'xsd', 'http://www.w3.org/2001/XMLSchema'
        doc.add_namespace 'xsi', 'http://www.w3.org/2001/XMLSchema-instance'
        doc.add_namespace 'tns', 'http://schemas.microsoft.com/sharepoint/soap/directory/'
        doc.add_namespace 'z', '#RowsetSchema'
        @debug.write "************ RESPONSE ************\n#{doc.to_s}\n*********************************" if $DEBUG
      end
      
      def on_after_create_http_request(req)
        if(@@config.has_key?(@site) and ! @@config[@site].nil?)
           req.set_auth(@@config[@site][:user],@@config[@site][:pass])
        else
           req.set_auth(@@config[:default][:user],@@config[:default][:pass])
        end
        @debug.write "************ REQUEST ************\n#{req.headers}\n*********************************" if $DEBUG
        @debug.write "************ REQUEST ************\n#{req.body}\n*********************************" if $DEBUG
      end
      # ********** End Hooks **********

      # GetUserInfo[]
      # input: username in the form of 'DOMAIN\username'
      def get_user_info(username)
        soap_action = SOAP_ACTION_PREFIX + 'GetUserInfo'
        response = invoke('spsoap:GetUserInfo', :soap_action => soap_action) do |root|
          build!(root) do
            user_login_name!(username)
          end
        end
        parse!(response)
      end



      # GetUserLoginFromEmail[http://msdn.microsoft.com/en-us/library/ms774890.aspx]
      def get_user_login_from_email(email)
        soap_action = SOAP_ACTION_PREFIX + 'GetUserLoginFromEmail'
        response = invoke('spsoap:GetUserLoginFromEmail', :soap_action => soap_action) do |root|
          build!(root) do
            email_xml!([email])
          end
        end
        parse!(response)
      end

      # GetUserCollectionFromSite
      def get_user_collection_from_site
        soap_action = SOAP_ACTION_PREFIX + 'GetUserCollectionFromSite'
        response = invoke('spsoap:GetUserCollectionFromSite', :soap_action => soap_action)
        parse!(response)
      end

      
      # Private Methods (Builders and Parsers)
      private
      
            
      def build!(node, opts = {}, &block)
        UserGroupBuilder.new(node, opts, &block)
      end

      def parse!(response, opts = {})
        UserGroupParser.new(response).parse(opts)
      end
    
    end # UserGroupService class
  end # SPWS module
end # Viewpoint module
