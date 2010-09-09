require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe Neo4j do

  # restore the configuration
  after(:all) { Neo4j::Config.setup }


  after(:each) do
    Neo4j::Transaction.finish
    Neo4j.shutdown
    FileUtils.rm_rf Neo4j::Config[:storage_path]
  end

  def create_new_storage(path)
    Neo4j::Config.use { |c| c[:storage_path] = path }
    FileUtils.rm_rf Neo4j::Config[:storage_path]
    File.should_not exist(path)
  end

  it "#ref_node returns the reference node" do
    Neo4j.ref_node.should be_kind_of(Java::org.neo4j.graphdb.Node)
  end

  it "#all_nodes returns a Enumerable of all nodes in the graph database " do
    # given created three nodes in a clean database
    create_new_storage('tmp/foo')
    created_nodes = Neo4j::Transaction.run { 3.times.map{ Neo4j::Node.new.id }}

    # when
    found_nodes = Neo4j.all_nodes.map {|node| node.id}

    # then
    found_nodes.should include(*created_nodes)
    found_nodes.should include(Neo4j.ref_node.id)
    found_nodes.size.should == 4
  end

  it "is possible to configure a new location of the database on the filesystem" do
    create_new_storage('tmp/foo')

    Neo4j::Transaction.new
    Neo4j::Node.new
    File.should exist('tmp/foo')
    Neo4j::Transaction.finish
  end
end