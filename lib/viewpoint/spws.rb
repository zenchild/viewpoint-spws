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
require 'kconv' if(RUBY_VERSION.start_with? '1.9') # bug in rubyntlm with ruby 1.9.x
require 'base64'
require 'httpclient'
require 'uri'
require 'nokogiri'
require 'logging'
require 'pathname'
require 'tzinfo'

# This is the base module for all other classes
module Viewpoint
  module SPWS
    attr_reader :logger
    Logging.logger.root.level = :info
    Logging.logger.root.appenders = Logging.appenders.stdout

    def self.root_logger
      Logging.logger.root
    end

    def self.set_log_level(level)
      Logging.logger.root.level = level
    end
  end
end
require 'viewpoint/spws/version'

# ----- Monkey Patches -----
require 'extensions/string'

# ----- Library Files -----
require 'viewpoint/spws/connection'
require 'viewpoint/spws/websvc/web_service_base'
# Copy Web Service
require 'viewpoint/spws/websvc/copy'
# Lists Web Service
require 'viewpoint/spws/websvc/lists'
require 'viewpoint/spws/types'
require 'viewpoint/spws/types/list'
require 'viewpoint/spws/types/tasks_list'
require 'viewpoint/spws/types/document_library'
require 'viewpoint/spws/types/list_item'
# User and Groups Web Service
require 'viewpoint/spws/websvc/user_group'
require 'viewpoint/spws/types/user'

require 'viewpoint/spws/spws_client'
