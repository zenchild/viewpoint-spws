$: << File.dirname(__FILE__) + '/../lib/'
require 'yaml'
require 'date'
require 'viewpoint_spws'

# To run these tests put configuration into a file called site_info.yaml
# --- 
# :site: sp_site_base
# :user: user
# :pass: pass

module SpecHelper
  def self.specdir
    File.dirname(__FILE__)
  end
end

RSpec.configure do |config|
  config.before(:all) do
    @conf = YAML.load(File.open("#{SpecHelper.specdir}/site_info.yaml",'r'))
  end
end
