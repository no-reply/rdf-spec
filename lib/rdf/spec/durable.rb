require 'rdf/spec'

# To use RDF::Durable to check that a repository maintains information between
# instantiations, add a Proc that creates a repository before each item, and
# clean that up after every run.  Example:
#describe RDF::DataObjects::Repository do
#  context "The SQLite adapter" do
#    before :each do
#      @repository = RDF::DataObjects::Repository.new "sqlite3://:memory:"
#      @load_durable = lambda { RDF::DataObjects::Repository.new "sqlite3:test.db" }
#    end
#
#    after :each do
#      File.delete('test.db') if File.exists?('test.db')
#    end
#
#    include RDF_Repository
#  end
#end
module RDF_Durable
  extend RSpec::SharedContext
  include RDF::Spec::Matchers

  before :each do
    raise '+@load_durable+ must be defined in a before(:each) block' unless instance_variable_get('@load_durable')
  end

  describe RDF::Durable do
    subject {@load_durable.call}
    it {should respond_to(:durable?)}
    it "should support #durable?" do
      expect([true,false]).to be_member(subject.durable?)
    end

    it {should respond_to(:nondurable?)}
    it "should support #nondurable?" do
      expect([true,false]).to be_member(@load_durable.call.nondurable?)
    end
    its(:nondurable?) {should_not == subject.durable?}

    it "should save contents between instantiations" do
      if subject.durable?
       subject.load(RDF::Spec::TRIPLES_FILE)
       expect(subject.count).to eq File.readlines(RDF::Spec::TRIPLES_FILE).size
      end
    end
  end
end
