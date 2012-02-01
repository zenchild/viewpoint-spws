Viewpoint for Sharepoint Web Services
================================


## Example Usage

### Connecting
```ruby
require 'viewpoint/spws'
site = 'https://myspsite/site_a/Default.aspx'
# If using GSSAPI and the 'gssapi' gem you do not need to specify a user/pass
scli = Viewpoint::SPWSClient.new(site)
# Otherwise you can specify a user/pass
scli = Viewpoint::SPWSClient.new(site, user, pass)
```

### Getting Lists
```ruby
# Retrieve all Lists for this site
lists = scli.get_lists
# Retrieve a specific list
taskl = scli.get_list('Task List')
# Retrieve a specific list by GUID
mylist = scli.get_list('{9202CCD0-2EA7-012F-0C9A-58D3859A6B00}')
```

### Information about a List
```ruby
taskl.title
# => "Task List" 
taskl.description
# => "Test Task List" 
taskl.created
# => #<DateTime: 2010-02-17T04:44:28+00:00 ((2455245j,17068s,0n),+0s,2299161j)> 
taskl.modified 
# => #<DateTime: 2012-01-09T06:03:25+00:00 ((2455936j,21805s,0n),+0s,2299161j)> 

```

### Retrieving Items
```ruby
# Retrieves an Array of Items
tasks = taskl.items
```
