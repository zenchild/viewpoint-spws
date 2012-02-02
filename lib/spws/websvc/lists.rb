=begin
  This file is part of ViewpointSPWS; the Ruby library for Microsoft Sharepoint Web Services.

  Copyright © 2011 Dan Wanek <dan.wanek@gmail.com>

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
=end

# This class represents the Sharepoint Lists Web Service.
# @see http://msdn.microsoft.com/en-us/library/ms774654(v=office.12).aspx
class Viewpoint::SPWS::Websvc::Lists
  include Viewpoint::SPWS::Websvc::WebServiceBase

  def initialize(spcon)
    @default_ns  = 'http://schemas.microsoft.com/sharepoint/soap/'
    @ws_endpoint = '_vti_bin/Lists.asmx'
    super
  end

  # Add a List to this site.
  # @see http://msdn.microsoft.com/en-us/library/lists.lists.addlist(v=office.12).aspx
  # @param [String] name A name for the List
  # @param [String] desc A description of the List
  # @param [Integer] templ_id The template type for this List. See the Microsoft docs for
  #   additional information.
  # @return [Viewpoint::SPWS::List] The new List object
  def add_list(name, desc, templ_id)
    soapmsg = build_soap_envelope do |type, builder|
      if(type == :header)
      else
        builder.AddList {
          builder.parent.default_namespace = @default_ns
          builder.listName(name)
          builder.description(desc)
          builder.templateID(templ_id)
        }
      end
    end
    soaprsp = Nokogiri::XML(send_soap_request(soapmsg.doc.to_xml))
    return soaprsp
    ns = {"xmlns"=> @default_ns}
    new_list(soaprsp.xpath('//xmlns:AddListResult/xmlns:List', ns).first)
  end

  # Add a List to this site from a feature ID.
  # @see http://msdn.microsoft.com/en-us/library/lists.lists.addlistfromfeature(v=office.12).aspx
  # @param [String] name A name for the List
  # @param [String] desc A description of the List
  # @param [String] feature_id The GUID of the feature ID.
  # @param [Integer] templ_id The template type for this List. See the Microsoft docs for
  #   additional information.
  # @return [Viewpoint::SPWS::List] The new List object
  def add_list_from_feature(name, desc, feature_id, templ_id)
    soapmsg = build_soap_envelope do |type, builder|
      if(type == :header)
      else
        builder.AddListFromFeature {
          builder.parent.default_namespace = @default_ns
          builder.listName(name)
          builder.description(desc)
          builder.featureID(feature_id)
          builder.templateID(templ_id)
        }
      end
    end
    soaprsp = Nokogiri::XML(send_soap_request(soapmsg.doc.to_xml))
    ns = {"xmlns"=> @default_ns}
    new_list(soaprsp.xpath('//xmlns:AddListResult/xmlns:List', ns).first)
  end

  # Delete a list from this site.
  # @param [String] name Either the name or the GUID of the list
  # @todo Work out the return value
  def delete_list(name)
    soapmsg = build_soap_envelope do |type, builder|
      if(type == :header)
      else
        builder.DeleteList {
          builder.parent.default_namespace = @default_ns
          builder.listName(name)
        }
      end
    end
    soaprsp = Nokogiri::XML(send_soap_request(soapmsg.doc.to_xml))
    #ns = {"xmlns"=> @default_ns}
  end

  # Returns a collection of content type definition schemas
  # @see http://msdn.microsoft.com/en-us/library/lists.lists.getlistcontenttypes(v=office.12).aspx
  # @param [String] name Either the name or the GUID of the list
  # @param [String] content_type_id (nil) The content type ID. I'm still not clear on what specifying
  #   this value does. In my limitted testing it does not seem to have an effect on the output.
  # @todo Work out the return value
  def get_list_content_types(name, content_type_id = nil)
    soapmsg = build_soap_envelope do |type, builder|
      if(type == :header)
      else
        builder.GetListContentTypes {
          builder.parent.default_namespace = @default_ns
          builder.listName(name)
          builder.contentTypeId(content_type_id)
        }
      end
    end
    soaprsp = Nokogiri::XML(send_soap_request(soapmsg.doc.to_xml))
  end

  # Returns all the lists for a Sharepoint site.
  # @param [Boolean] show_hidden Whether or not to show hidden lists. Default = false
  # @see http://msdn.microsoft.com/en-us/library/lists.lists.getlistcollection(v=office.12).aspx
  def get_list_collection(show_hidden = false)
    soapmsg = build_soap_envelope do |type, builder|
      if(type == :header)
      else
        builder.GetListCollection {
          builder.parent.default_namespace = @default_ns
        }
      end
    end
    soaprsp = Nokogiri::XML(send_soap_request(soapmsg.doc.to_xml))
    ns = {"xmlns"=> @default_ns}
    lists = []
    soaprsp.xpath('//xmlns:Lists/xmlns:List', ns).each do |l|
      lists << new_list(l)
    end
    if(!show_hidden)
      lists.reject! do |i|
        i.hidden?
      end
    end
    lists
  end

  # Retrieve a specific Sharepoint List
  # @see http://msdn.microsoft.com/en-us/library/lists.lists.getlist(v=office.12).aspx
  # @param [String] list title or the GUID for the list
  # @return [Viewpoint::SPWS::List]
  def get_list(list)
    soapmsg = build_soap_envelope do |type, builder|
      if(type == :header)
      else
        builder.GetList {
          builder.parent.default_namespace = @default_ns
          builder.listName(list)
        }
      end
    end
    soaprsp = Nokogiri::XML(send_soap_request(soapmsg.doc.to_xml))
    ns = {"xmlns"=> @default_ns}
    new_list(soaprsp.xpath('//xmlns:GetListResult/xmlns:List', ns).first)
  end

  # Get List Items based on certain parameters
  # @see http://msdn.microsoft.com/en-us/library/lists.lists.getlistitems(v=office.12).aspx
  # @param [String] list title or the GUID for the list
  # @param [Hash] opts
  # @option opts [String] :view_name ('') GUID for the view surrounded by curly braces 
  #   If nothing is passed it used the default of the View
  # @option opts [String] :row_limit ('') A String representing the number of rows to return.
  # @option opts [Boolean] :recursive (true) If true look in subfolders as well as root
  # @option opts [Boolean] :date_in_utc (true) If true return dates in UTC
  # @option opts [String]  :folder ('') 
  #   Filter document library items for items in the specified folder
  # @yield [builder] Yields a Builder object that can be used to build a CAML Query. See the
  #   example on how to use it.
  # @yieldparam [Nokogiro::XML::Builder] builder The builder object used to create the Query
  # @example The following example shows how to prepare a CAML Query with a block. It filters for all objects of ObjectType '0' = Files
  #   items = listws.get_list_items('Shared Documents',:recursive => true) do |b|
  #     b.Query {
  #       b.Where {
  #         b.Eq {
  #           b.FieldRef(:Name => 'FSObjType')
  #           b.Value(0, :Type => 'Integer')
  #         }
  #       }
  #     }
  #   end
  def get_list_items(list, opts = {})
    # Set Default values
    opts[:recursive] = true unless opts.has_key?(:recursive)
    opts[:view_name] = '' unless opts.has_key?(:view_name)
    opts[:row_limit] = '' unless opts.has_key?(:row_limit)
    opts[:date_in_utc] = true unless opts.has_key?(:date_in_utc)
    opts[:folder] = '' unless opts.has_key?(:folder)

    soapmsg = build_soap_envelope do |type, builder|
      if(type == :header)
      else
        builder.GetListItems {
          builder.parent.default_namespace = @default_ns
          builder.listName(list)
          builder.viewName(opts[:view_name])
          builder.rowLimit(opts[:row_limit])

          if block_given?
            builder.query {
              builder.parent.default_namespace = ''
              yield builder
            }
          end

          builder.queryOptions {
            builder.QueryOptions {
              builder.parent.default_namespace = ''
              builder.Folder(opts[:folder])
              builder.ViewAttributes(:Scope => 'Recursive') if opts[:recursive]
              builder.DateInUtc('True') if opts[:date_in_utc]
              builder.IncludeAttachmentUrls('True')
            }
          }
          # @todo Is this worth supporting???
          #builder.webID(parms[:web_id])
        }
      end
    end
    soaprsp = Nokogiri::XML(send_soap_request(soapmsg.doc.to_xml))
    ns = {'xmlns:z' => "#RowsetSchema"}
    items = []
    soaprsp.xpath('//z:row', ns).each do |li|
      items << Types::ListItem.new(self, list, li)
    end
    items
  end

  # Get List Items changes from a given change token
  # @see http://msdn.microsoft.com/en-us/library/lists.lists.getlistitemchangessincetoken(v=office.12).aspx
  # @param [String] list title or the GUID for the list
  # @param [String] token (nil) The change token or nil to get all
  # @param [Hash] opts
  # @option opts [String] :view_name ('') GUID for the view surrounded by curly braces 
  #   If nothing is passed it used the default of the View
  # @option opts [String] :row_limit ('') A String representing the number of rows to return.
  # @option opts [Boolean] :recursive (true) If true look in subfolders as well as root
  # @option opts [Boolean] :date_in_utc (true) If true return dates in UTC
  # @option opts [String]  :folder ('') 
  #   Filter document library items for items in the specified folder
  # @yield [builder] Yields a Builder object that can be used to build a CAML Query. See the
  #   example on how to use it.
  # @yieldparam [Nokogiro::XML::Builder] builder The builder object used to create the Query
  # @example The following example shows how to prepare a CAML Query with a block. It filters for all objects of ObjectType '0' = Files
  #   items = listws.get_list_items('Shared Documents',:recursive => true) do |b|
  #     b.Query {
  #       b.Where {
  #         b.Eq {
  #           b.FieldRef(:Name => 'FSObjType')
  #           b.Value(0, :Type => 'Integer')
  #         }
  #       }
  #     }
  #   end
  # @return [Hash] returns a Hash with the keys :last_change_token, which contains a String
  #   that holds a change token that may be used in subsequent calls, and :items which holds
  #   an Array of ListItem objects.
  def get_list_item_changes_since_token(list, token=nil, opts = {})
    # Set Default values
    opts[:recursive] = true unless opts.has_key?(:recursive)
    opts[:view_name] = '' unless opts.has_key?(:view_name)
    opts[:row_limit] = '' unless opts.has_key?(:row_limit)
    opts[:date_in_utc] = true unless opts.has_key?(:date_in_utc)
    opts[:folder] = '' unless opts.has_key?(:folder)

    soapmsg = build_soap_envelope do |type, builder|
      if(type == :header)
      else
        builder.GetListItemChangesSinceToken {
          builder.parent.default_namespace = @default_ns
          builder.listName(list)
          builder.viewName(opts[:view_name])
          builder.rowLimit(opts[:row_limit])

          if block_given?
            builder.query {
              builder.parent.default_namespace = ''
              yield builder
            }
          end

          builder.queryOptions {
            builder.QueryOptions {
              builder.parent.default_namespace = ''
              builder.Folder(opts[:folder])
              builder.ViewAttributes(:Scope => 'Recursive') if opts[:recursive]
              builder.DateInUtc('True') if opts[:date_in_utc]
              builder.IncludeAttachmentUrls('True')
            }
          }

          builder.changeToken(token)
          # @todo Is this worth supporting???
          #builder.contains()
        }
      end
    end
    soaprsp = Nokogiri::XML(send_soap_request(soapmsg.doc.to_xml))
    ns = {'xmlns:z' => "#RowsetSchema",
         'xmlns:rs' => "urn:schemas-microsoft-com:rowset",
         'xmlns'    => @default_ns,
    }
    items = []
    soaprsp.xpath('//rs:data/z:row', ns).each do |li|
      items << Types::ListItem.new(self, list, li)
    end
    changes = soaprsp.xpath('//xmlns:GetListItemChangesSinceTokenResult/xmlns:listitems/xmlns:Changes',ns).first
    {:last_change_token => changes['LastChangeToken'], :items => items}
  end

  # Adds, deletes, or updates the specified items in a list
  # @see http://msdn.microsoft.com/en-us/library/lists.lists.updatelistitems(v=office.12).aspx
  # @see BATCH Operation http://msdn.microsoft.com/en-us/library/ms437562(v=office.12).aspx
  # @param [String] list title or the GUID for the list
  # @param [Hash] updates
  # @option updates [String] :view_name ('') GUID for the view without curly braces 
  #   If nothing is passed it used the default of the View
  # @option updates [String] :on_error ('Continue') What to do if an error ocurrs. It must
  #   be either 'Return' or 'Contiue'
  # @option updates [String] :list_version ('') The version of the list we wish to modify
  # @option updates [String] :version ('') The version of Sharepoint we are acting on
  # @option updates [Array<Hash>] :item_updates An array of Hashes that specify what to update.
  #   Each hash needs an :id key to specify the item ID and a :command key that specifies
  #   "New", "Update" or "Delete". All other keys are field names in either CamelCase or
  #   ruby_case with values to set them to.
  #   {:item_updates =>
  #     [{:id => 95, :command => 'Update', :status => 'Completed'},
  #     {:id => 107, :command => 'Update', :title => "Test"}]}
  # @yield [builder] Yields a Builder object that can be used to build a Batch request. See the
  #   example on how to use it. For more information on Batch requests:
  #   @see http://msdn.microsoft.com/en-us/library/dd585784(v=office.11).aspx
  # @yieldparam [Nokogiro::XML::Builder] builder The builder object used to create the Batch
  # @example The following example shows how to prepare a Batch request with a block. It updates a Task item to Status 'Completed'.
  #   item_id = 95
  #   listws.update_list_items('Task List') do |b|
  #     b.Method(:ID => 1, :Cmd => 'Update') do
  #       b.Field(item_id,:Name => 'ID')
  #       b.Field("Completed", :Name => 'Status')
  #     end
  #   end
  # @example How to Add and Delete via passed parameters
  #   updates = [
  #     {:id => "New", :command => "New", :title => "Test Task"},
  #     {:id => 'New',:command => 'New', :title => 'Test Task 2'},
  #     {:id => 98,:command => 'Delete'},
  #   ]
  #   resp = listws.update_list_items('Task List',:item_updates => updates)
  def update_list_items(list, updates = {})
    # Set Default values
    updates[:view_name] = '' unless updates.has_key?(:view_name)
    updates[:on_error] = 'Continue' unless updates.has_key?(:on_error)
    updates[:list_version] = '' unless updates.has_key?(:list_version)
    updates[:version] = '' unless updates.has_key?(:version)

    soapmsg = build_soap_envelope do |type, builder|
      if(type == :header)
      else
        builder.UpdateListItems {
          builder.parent.default_namespace = @default_ns
          builder.listName(list)

          builder.updates {
            builder.Batch(:ViewName => updates[:view_name],
                          :OnError  => updates[:on_error],
                          :ListVersion  => updates[:list_version],
                          :Version  => updates[:version]) {
              builder.parent.default_namespace = ''

              # First format passed item_updates
              updates[:item_updates] && updates[:item_updates].each_with_index do |iu,idx|
                iu = iu.clone
                builder.Method(:ID => "VP_IDX#{idx}", :Cmd => iu.delete(:command)) do
                  builder.Field(iu.delete(:id), :Name => 'ID')
                  iu.each_pair do |k,v|
                    builder.Field(v, :Name => k.to_s.camel_case)
                  end
                end
              end

              # Now include block-passed updates
              if block_given?
                yield builder
              end
            }
          }
        }
      end
    end

    soaprsp = Nokogiri::XML(send_soap_request(soapmsg.doc.to_xml))
  end


  # ------------------------- Helper Methods ------------------------- #

  # Retrieve a file from Sharepoint. This is not a standard Web Service method, buth
  # rather a convenience method that is part of ViewpointSPWS.
  # @param [String] file_ref The fileref property from a ListItem object
  # @return [String] A String representing the bytestream of a file. You should be able
  #   to write it out to a file with something like this:
  # @example
  #   resp = listws.get_file(listitem.file_ref)
  #   File.open(listitem.file_name,'w+') do |f|
  #     f.write(resp)
  #   end
  def get_file(file_ref)
    p1 = Pathname.new @spcon.site_base.request_uri
    p2 = Pathname.new "/#{file_ref}"
    target = p2.relative_path_from p1
    @spcon.get(target.to_s)
  end


  private

  # Parse the SOAP Response and return an appropriate List type
  def new_list(xmllist)
    case xmllist['ServerTemplate']
    when "107"
      Types::TasksList.new(self, xmllist)
    else
      Types::List.new(self, xmllist)
    end
  end

end
