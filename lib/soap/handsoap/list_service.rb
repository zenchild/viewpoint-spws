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
    class ListService < Handsoap::Service
      include ConfigLoader
      
      load_config! # Loads the site config from .viewpointrc (See sp_config.rb) into @@config
      endpoint SPWS_ENDPOINT = {
        :uri => "#{SHAREPOINT_SITE}_vti_bin/lists.asmx",
        :version => 1
      }

      SOAP_ACTION_PREFIX='http://schemas.microsoft.com/sharepoint/soap/'

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
        doc.alias 'spsoap', 'http://schemas.microsoft.com/sharepoint/soap/'
      end
      
      def on_response_document(doc)
        doc.add_namespace 'soap', 'http://schemas.xmlsoap.org/soap/envelope/'
        doc.add_namespace 'xsd', 'http://www.w3.org/2001/XMLSchema'
        doc.add_namespace 'xsi', 'http://www.w3.org/2001/XMLSchema-instance'
        doc.add_namespace 'tns', 'http://schemas.microsoft.com/sharepoint/soap/'
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

      # AddList
      def add_list(title, description, server_template)
        soap_action = SOAP_ACTION_PREFIX + 'AddList'
        response = invoke('spsoap:AddList', :soap_action => soap_action) do |root|
          build!(root) do
            list_name!(title)
            description!(description)
            template_id!(server_template)
          end
        end
        parse!(response)
      end
      
      # DeleteList
      def delete_list(title)
        soap_action = SOAP_ACTION_PREFIX + 'DeleteList'
        response = invoke('spsoap:DeleteList', :soap_action => soap_action) do |root|
          build!(root) do
            list_name!(title)
          end
        end
        parse!(response)
      end


      # CheckOutFile[]
      def check_out_file(url, writeable = false)
        soap_action = SOAP_ACTION_PREFIX + 'CheckOutFile'
        response = invoke('spsoap:CheckOutFile', :soap_action => soap_action) do |root|
          build!(root) do
            page_url!(url)
            checkout_to_local!(writeable.to_s)
          end
        end
        parse!(response)
      end

      # GetAttachmentCollection[]
      def get_attachment_collection(list_item)
        soap_action = SOAP_ACTION_PREFIX + 'GetAttachmentCollection'
        response = invoke('spsoap:GetAttachmentCollection', :soap_action => soap_action) do |root|
          build!(root) do
            list_name!(list_item.list.title)
            list_item_id!(list_item.id)
          end
        end
        parse!(response)
      end

      # GetList
      # This will someday be used to flesh-out the SPList class and turn @shallow=false.
      def get_list(title, list = nil)
        soap_action = SOAP_ACTION_PREFIX + 'GetList'
        response = invoke('spsoap:GetList', :soap_action => soap_action) do |root|
          build!(root) do
            list_name!(title)
          end
        end
        parse!(response, {:list => list})
      end

      # GetListCollection[http://msdn.microsoft.com/en-us/library/dd586523(office.11).aspx]
      def get_list_collection()
        soap_action = SOAP_ACTION_PREFIX + 'GetListCollection'
        response = invoke('spsoap:GetListCollection', :soap_action => soap_action)
        #parse_list_collection(response)
        parse!(response)
      end
      
      # GetListItems[http://msdn.microsoft.com/en-us/library/dd586530(office.11).aspx]
      def get_list_items(list)
        soap_action = SOAP_ACTION_PREFIX + 'GetListItems'
        response = invoke('spsoap:GetListItems', :soap_action => soap_action) do |root|
          build!(root) do
            list_name!(list.title)
          end
        end
        parse!(response, {:list => list})
      end

      # GetListItemChanges[http://msdn.microsoft.com/en-us/library/dd586526(office.11).aspx]
      # list: Viewpoint::SPWS::SPList
      # date: String in ISO8601 (UTC) format
      #   Example.  (DateTime.now - 2).new_offset(0).to_s will print out a date 2 days earlier
      def get_list_item_changes(list, date)
        soap_action = SOAP_ACTION_PREFIX + 'GetListItemChanges'
        response = invoke('spsoap:GetListItemChanges', :soap_action => soap_action) do |root|
          build!(root) do
            list_name!(list.title)
            since!(date)
          end
        end
        parse!(response)
      end

      # UpdateListItems[http://msdn.microsoft.com/en-us/library/dd586543(office.11).aspx]
      # list: Viewpoint::SPWS::SPList
      # TODO: Implement a Hash input that will convert to a Batch Method in the WS
      # batch: a hash of Method attributes and fields
      #   {
      #     meth_id1 => {:Cmd => 'New', :fields => {:Title => 'My test title'}}
      #     meth_id2 => {:Cmd => 'Update', :fields => {:ID => '6', :Title => 'New Title Name'}}
      #   }
      #
      def update_list_items(list, batch = {})
        soap_action = SOAP_ACTION_PREFIX + 'UpdateListItems'
        response = invoke('spsoap:UpdateListItems', :soap_action => soap_action) do |root|
          build!(root) do
            list_name!(list.title)
            updates!(batch)
          end
        end
        parse!(response)
      end
      
      # Private Methods (Builders and Parsers)
      private
      
            
      def build!(node, opts = {}, &block)
        ListBuilder.new(node, opts, &block)
      end

      def parse!(response, opts = {})
        ListParser.new(response).parse(opts)
      end
    
    end # ListService class
  end # SPWS module
end # Viewpoint module
