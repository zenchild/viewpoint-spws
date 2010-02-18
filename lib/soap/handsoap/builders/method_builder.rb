module Viewpoint
  module Sharepoint
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
  end # Sharepoint
end # Viewpoint
