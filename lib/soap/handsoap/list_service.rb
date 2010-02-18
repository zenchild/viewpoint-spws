require 'rubygems'
require 'httpclient'
gem 'httpclient'
require 'handsoap'
require 'sp_list'
require 'sp_config'
require 'builders'
require 'parsers'

Handsoap.http_driver = :http_client

module Viewpoint
  module Sharepoint
    class ListService < Handsoap::Service
      include SPConfig
      
      load_config! # Loads the site config from .viewpointrc (See sp_config.rb) into @config
      endpoint( :uri => @@config.keys.first, :version => 1 )

      SOAP_ACTION_PREFIX='http://schemas.microsoft.com/sharepoint/soap/'

      def initialize()
        @endpoint = @@config.keys.first
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
        doc.add_namespace 'tns', 'http://schemas.microsoft.com/sharepoint/soap/'
        @debug.write "************ RESPONSE ************\n#{doc.to_s}\n*********************************" if $DEBUG
      end
      
      def on_after_create_http_request(req)
        req.set_auth(@@config[@endpoint][:user],@@config[@endpoint][:pass])
        @debug.write "************ REQUEST ************\n#{req.headers}\n*********************************" if $DEBUG
        @debug.write "************ REQUEST ************\n#{req.body}\n*********************************" if $DEBUG
      end
      # ********** End Hooks **********

      # GetList
      # This will someday be used to flesh-out the SPList class and turn @shallow=false.
      def get_list(list)
        soap_action = SOAP_ACTION_PREFIX + 'GetList'
        response = invoke('spsoap:GetList', :soap_action => soap_action) do |root|
          builder(root) do
            list_name!(list.title)
          end
        end
        #raise NotImplementedError
      end

      # GetListCollection[http://msdn.microsoft.com/en-us/library/dd586523(office.11).aspx]
      def get_list_collection()
        soap_action = SOAP_ACTION_PREFIX + 'GetListCollection'
        response = invoke('spsoap:GetListCollection', :soap_action => soap_action)
        parse_list_collection(response)
      end
      
      # GetListItems[http://msdn.microsoft.com/en-us/library/dd586530(office.11).aspx]
      def get_list_items(list)
        soap_action = SOAP_ACTION_PREFIX + 'GetListItems'
        response = invoke('spsoap:GetListItems', :soap_action => soap_action) do |root|
          builder(root) do
            list_name!(list.title)
          end
        end
        #parse_list_items(response)
      end

      # GetListItemChanges[http://msdn.microsoft.com/en-us/library/dd586526(office.11).aspx]
      # list: Viewpoint::Sharepoint::SPList
      # date: String in ISO8601 (UTC) format
      #   Example.  (DateTime.now - 2).new_offset(0).to_s will print out a date 2 days earlier
      def get_list_item_changes(list, date)
        soap_action = SOAP_ACTION_PREFIX + 'GetListItemChanges'
        response = invoke('spsoap:GetListItemChanges', :soap_action => soap_action) do |root|
          builder(root) do
            list_name!(list.title)
            since!(date)
          end
        end
      end

      # UpdateListItems[http://msdn.microsoft.com/en-us/library/dd586543(office.11).aspx]
      # list: Viewpoint::Sharepoint::SPList
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
          builder(root) do
            list_name!(list.title)
            updates!(batch)
          end
        end
      end
      
      # Private Methods (Builders and Parsers)
      private
      
      def parse_list_collection(xml)
        lists = []
        (xml/'//tns:List').each do |l|
          lists << SPList.new(l['ID'], l['Title'], l['Description'], l['DefaultViewUrl'], l['WebFullUrl'], l['ServerTemplate'])
        end
        lists
      end
      
      def parse_list_items(xml)
      end

      def builder(node, opts = {}, &block)
        ListBuilder.new(node, opts, &block)
      end
    
    end # ListService class
  end # Sharepoint module
end # Viewpoint module
