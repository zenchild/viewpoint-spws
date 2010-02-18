require 'list_service'
gl = Viewpoint::Sharepoint::ListService.new()
lists = gl.get_list_collection
gl.get_list(lists[8])
methods = {
  '0,TestID' => {:Cmd => 'New', :fields => {:Title => 'My test new title'}},
  '1,TestID' => {:Cmd => 'New', :fields => {:Title => 'My test new title2'}}
  }

gl.update_list_items(lists[8],methods)

=begin
lists.each do |l|
  puts l.title
  puts "\t#{l.id}"
  puts "\t#{l.description}"
  puts "\t#{l.web_full_url}"
  puts "\t#{l.default_view_url}"
  puts "\t#{l.server_template}"
end
=end
