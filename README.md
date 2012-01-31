Viewpoint for Sharepoint Web Services
================================


## Example Usage

1. Loading
```ruby
require 'viewpoint_spws'
```
1. Getting a Task List
```ruby
site = 'https://myspsite/site_a/Default.aspx'
scli = Viewpoint::SPWSClient.new(site)

lws = scli.lists_ws # Get the List Web Service
tasklist = lws.get_list('Task List')
items = tasklist.items # Fetch the individual Tasks
```
