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

# This class represents a Sharepoint List returned from the Lists Web Service with a
# ServerTemplate id of 107 (Tasks).
# @see http://msdn.microsoft.com/en-us/library/ms774810(v=office.12).aspx
class Viewpoint::SPWS::Types::TasksList < Viewpoint::SPWS::Types::List

  # Add a Task to this List
  # @param [Hash] opts parameters for this Task
  # @option opts [String] :title The title of this Task
  def add_item!(opts)
    raise "Title argument required" unless opts[:title]

    title = opts[:title]
    op = [{ :command => 'New', :id => 'New',
      :title => opts[:title] }]
    @ws.update_list_items(@guid, :item_updates => op)
  end

end
