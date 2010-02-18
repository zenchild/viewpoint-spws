module Viewpoint
  module Sharepoint
    module Field
      def Field.build(node,name,value)
        node.add('Field',value) do |field|
          field.set_attr('Name',name)
        end
      end
    end # Field
  end # Sharepoint
end # Viewpoint
