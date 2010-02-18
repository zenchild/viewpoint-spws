module Viewpoint
  module Sharepoint
    module Batch
      def Batch.build(node, methods)
        node.add('Batch') do |batch|
          methods.each_pair do |k,v|
            Method.build(batch,k,v[:Cmd],v[:fields])
          end
        end
      end
    end # Batch
  end # Sharepoint
end # Viewpoint
