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

module Viewpoint::SPWS
  module Types
    PRIORITY  = {:high => '(1) High', :normal => '(2) Normal', :low => '(3) Low'}.freeze

    STATUS    = {:not_started => 'Not Started', :in_progress => 'In Progress',
      :completed => 'Completed', :deferred => 'Deferred',
      :waiting => 'Waiting on someone else'}.freeze
  end
end
