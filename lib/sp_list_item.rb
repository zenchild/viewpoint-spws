module Viewpoint
  module Sharepoint
    class SPListItem

      attr_reader :id

      def initialize(id)
        @id = id
      end
    end
  end
end
