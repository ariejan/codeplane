shared_examples_for "resource collection" do
  it "returns a collection" do
    subject.send(collection).should be_a(Codeplane::Collection)
  end

  it "sets resource's path" do
    subject.send(collection).resource_path.should == resource_path
  end

  it "sets resource's class name" do
    subject.send(collection).resource_class_name.should == resource_class_name
  end

  it "returns resource's class" do
    subject.send(collection).resource_class.should == resource_class
  end

  it "sets parent" do
    subject.send(collection).parent.should == subject
  end
end
