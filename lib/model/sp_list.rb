module Viewpoint
  module Sharepoint
    class SPList

      attr_reader :id, :title, :description, :default_view_url, :web_full_url, :server_template

      def initialize(id, title, description, default_view_url, web_full_url, server_template)
        @id = id
        @title = title
        @description = description
        @default_view_url = default_view_url
        @web_full_url = web_full_url
        @server_template = server_template
        @shallow = true
      end
    end
  end
end
