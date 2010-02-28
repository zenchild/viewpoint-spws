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
      module Method
        def Method.build(node,id,cmd,fields)
          node.add('Method') do |meth|
            meth.set_attr('ID', id)
            meth.set_attr('Cmd',cmd)
            fields.each_pair do |f_name,f_value|
              Field.build(meth,f_name.to_s,f_value)
            end
          end
        end
      end # Method
    end # SOAP
  end # SPWS
end # Viewpoint
