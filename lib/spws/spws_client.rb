# This class is the glue between the Models and the Web Service.
class Viewpoint::SPWSClient
  include Viewpoint::SPWS

  # Initialize the SPWSClient instance.
  # @param [String] endpoint The SPWS endpoint we will be connecting to
  # @param [String] user The user to authenticate as. If you are using
  #   NTLM or Negotiate authentication you do not need to pass this parameter.
  # @param [String] pass The user password. If you are using NTLM or
  #   Negotiate authentication you do not need to pass this parameter.
  def initialize(endpoint, user = nil, pass = nil)
    @con = Connection.new(endpoint)
    @con.set_auth(user,pass) if(user && pass)
  end

  def copy_ws
    @copyws ||= Copy.new(@con)
  end

  def lists_ws
    @listsws ||= Lists.new(@con)
  end

  def usergroup_ws
    @usergroupws ||= UserGroup.new(@con)
  end


  # ========= List Accessor Proxy Methods ========= 

  # Available list types that can be used for #add_list
  LIST_TYPES = {
    :announcements  => 104,
    :contacts       => 105,
    :custom_list    => 100,
    :custom_list_for_datasheet => 120,
    :datasources    => 110,
    :discussion_board => 108,
    :document_library => 101,
    :events         => 106,
    :form_library   => 115,
    :issues         => 1100,
    :links          => 103,
    :picture_library => 109,
    :survey         => 102,
    :tasks          => 107
  }

  # Retrieve all of the viewable lists for this site.
  def get_lists
    lists_ws.get_list_collection
  end

  # Retrieve a List object
  # @param [String] list title or the GUID for the list
  def get_list(list)
    lists_ws.get_list('Task List')
  end

  # Add a List to thiis site
  # @param [String] name A name for the List
  # @param [String] desc A description of the List
  # @param [Integer] list_type The list template id. Use the LIST_TYPES Hash.
  def add_list(name, desc, list_type)
    lists_ws.add_list(name, desc, list_type)
  end

  # Delete a list from this site.
  # @param [String] list title or the GUID for the list
  def delete_list(list)
    lists_ws.delete_list(list)
  end

end
