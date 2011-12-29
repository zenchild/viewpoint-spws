$: << File.dirname(__FILE__)
require 'spec_helper'

describe 'Test the Sharepoint List web service functionality' do
  before(:all) do
    con = Viewpoint::SPWS::Connection.new(@conf[:site])
    con.set_auth(@conf[:user],@conf[:pass])
    @lws = con.lists_ws
  end

  it 'should retrieve the Lists from a given Sharepoint site' do
    lists = @lws.get_list_collection(true)
    lists.should be_an_instance_of(Array)
    lists.first.should be_an_instance_of(Viewpoint::SPWS::List)
  end

  it 'should retrieve the Items from a given List'

end
