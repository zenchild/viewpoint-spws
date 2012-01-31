Viewpoint for Sharepoint Web Services
================================


## Example Usage

### Loading the library

```ruby
require 'viewpoint_spws'
```

### Getting a Task List
```ruby
site = 'https://myspsite/site_a/Default.aspx'
scli = Viewpoint::SPWSClient.new(site)
lws = scli.lists_ws # Get the List Web Service
tasklist = lws.get_list('Task List')
items = tasklist.items # Fetch the individual Tasks
```