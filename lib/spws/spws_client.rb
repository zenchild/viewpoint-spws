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

end
