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
lists = scli.get_lists  # Retrieve all Lists for this site
tasks = scli.get_list('Task List') # Retrieve a specific list
items = tasklist.items # Fetch the individual Tasks
```
