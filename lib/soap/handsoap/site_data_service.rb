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
    module SOAP
    class SiteDataService < Handsoap::Service
      include ConfigLoader
      
      load_config! # Loads the site config from .viewpointrc (See sp_config.rb) into @@config
      endpoint SPWS_ENDPOINT = {
        :uri => "#{SHAREPOINT_SITE}_vti_bin/sitedata.asmx",
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

      
      # Private Methods (Builders and Parsers)
      private
      
            
      def build!(node, opts = {}, &block)
        SiteDataBuilder.new(node, opts, &block)
      end

      def parse!(response, opts = {})
        SiteDataParser.new(response).parse(opts)
      end
    
    end # SiteDataService class
    end # SOAP module
  end # SPWS module
end # Viewpoint module
