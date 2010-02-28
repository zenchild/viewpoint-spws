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
module Viewpoint
  module SPWS
    module SOAP
      class UserGroupBuilder
        def initialize(node, opts, &block)
          @node, @opts = node, opts
          instance_eval(&block) if block_given?
        end

        def user_login_name!(username)
          @node.add('spsoap:userLoginName',username)
        end

        def email_xml!(emails)
          @node.add('spsoap:emailXml') do |emailXml|
            emailXml.add('Users') do |usrs|
              emails.each do |email|
                usrs.add('User') do |u|
                  u.set_attr('email', email)
                end
              end
            end
          end
        end

      end # UserGroupBuilder
    end # SOAP
  end # SPWS
end # Viewpoint
