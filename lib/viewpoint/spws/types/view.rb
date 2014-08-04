class Viewpoint::SPWS::Types::View
  include Viewpoint::SPWS::Types

  attr_reader :name, :default_view, :mobile_view, :mobile_default_view, :type
  attr_reader :display_name, :url, :level, :base_viewID, :content_typeID, :imageUrl
  attr_reader :view_fields

  def initialize(ws, xml)
    @ws = ws
    @view_fields = nil
    parse_xml_fields(xml)
    ns = {"xmlns" => xml.namespace.href}
    xml.xpath('//xmlns:ViewFields/xmlns:FieldRef', ns).each do |l|
        @view_fields ||= []
        @view_fields << l.attributes['Name'].value
    end
  end

  def parse_xml_fields(xml)
    [:name, :default_view, :mobile_view, :mobile_default_view, :type,
     :display_name, :url, :level, :base_viewID, :content_typeID, :imageUrl].each do |a|
	# var = "@#{a}".to_sym
        # val = xml[a.to_s.camel_case]
	# puts "#{var.inspect} -> #{val.inspect}"
	instance_variable_set   "@#{a}".to_sym, xml[a.to_s.camel_case]
    end
  end
end
