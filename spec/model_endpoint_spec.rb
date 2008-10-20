require 'spec/model_spec_helper.rb'

describe Endpoint do
  before(:all) do
    ModelSpecHelper.setup_database
  end
  before(:each) do
    Endpoint.delete_all
  end
end

