Viewpoint for Sharepoint Web Services
================================
This is a Ruby client library for Sharepoint Web Services. If you've used my [Viewpoint library for Exchange Web Services](https://github.com/zenchild/Viewpoint) you will no doubt notice a similar feel to this library.  It however cannot be a one-for-one do to the way Sharepoint splits its web services among many different services.

There is still quite a lot that needs to be done with the model layer. However, if you are a more daring personality the web service back-end is fairly complete for the web services I've chosen to expose thus far. I've also tried to document each back-end method to its fullest and to provide links to the Microsoft docs where I fall short. Documentation should be up to date on [rubydoc.info](http://rubydoc.info/github/zenchild/viewpoint-spws/frames).


## Example Usage

### Connecting
```ruby
require 'viewpoint/spws'
site = 'https://myspsite/site_a/Default.aspx'
# If using GSSAPI and the 'gssapi' gem you do not need to specify a user/pass
scli = Viewpoint::SPWSClient.new(site)
# Otherwise you can specify a user/pass
scli = Viewpoint::SPWSClient.new(site, user, pass)
# You can also specify a timezone (more on this below)
scli = Viewpoint::SPWSClient.new(site, user, pass, 'Australia/Melbourne')
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

### Creating/Renaming/Deleting a Task (other types of ListItems are forthcoming)
```ruby
t1 = taskl.add_item!(:title => "New Task")
# Set and call #save!
t1.rename  'My New Task'
t1.save!
# or use the autosave method
t1.rename! "My Really New Task"
# or use an auto-saving transaction
t1.update! do |l|
  l.rename 'New Name'
  l.set_priority :low
  l.set_status :waiting
end
t1.delete!
```

### Upload a file to a DocumentLibrary List
```ruby
doclib = scli.get_list 'Personal Documents'
doclib.add_file! :file => '/path/to/file'
```

## Timezones
SPWS servers return times in the zone the Sharepoint Web Front End (WFE) is configured in. For example, say I have a Sharepoint WFE located in Perth, Australia (GMT+8, no DST), with its system time set to local time. If Sharepoint wishes to express the actual time `2014-01-01T00:00:00Z`, the string `2014-01-01T08:00:00Z` will be returned by the web service, which is incorrect unless the timezone fragment is ignored.

To work around this, a timezone can be specified while creating the SPWS client object. This will cause the times returned by SharePoint to be converted correctly.

### My Links
- [Twitter | https://twitter.com/zentourist](https://twitter.com/#!/zentourist)
- [BLOG | http://distributed-frostbite.blogspot.com/](http://distributed-frostbite.blogspot.com/)
- [LinkedIn | http://www.linkedin.com/in/danwanek](http://www.linkedin.com/in/danwanek)
- Find me on irc.freenode.net in #ruby-lang (zenChild)
