$: << File.dirname(__FILE__)
require 'spec_helper'

describe 'Test the Sharepoint List web service functionality' do
  before(:all) do
    @scli = Viewpoint::SPWSClient.new(@conf[:site], @conf[:user], @conf[:pass])
  end

  it 'should return the Lists web service' do
    @scli.lists_ws.should be_an_instance_of Viewpoint::SPWS::Websvc::Lists
  end

  it 'should return the Copy web service' do
    @scli.copy_ws.should be_an_instance_of Viewpoint::SPWS::Websvc::Copy
  end

  it 'should return the UserGroup web service' do
    @scli.usergroup_ws.should be_an_instance_of Viewpoint::SPWS::Websvc::UserGroup
  end

  it 'should retrieve the Lists from a given Sharepoint site' do
    lists = @scli.get_lists
    lists.should be_an_instance_of(Array)
    lists.first.should be_a_kind_of(Viewpoint::SPWS::Types::List)
  end

  it 'should retrieve the Items from a given List' do
    lists = @scli.get_lists
    items = lists.first.items
    items.should be_an_instance_of(Array)
  end

  it 'should retrieve a User given a domain login' do
    u = @scli.get_user @conf[:user_login]
    u.should be_an_instance_of(Viewpoint::SPWS::Types::User)
  end

  it 'should retrieve a User given an e-mail' do
    u = @scli.get_user @conf[:user_email]
    u.should be_an_instance_of(Viewpoint::SPWS::Types::User)
  end

end
