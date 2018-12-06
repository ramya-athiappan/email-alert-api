RSpec.describe FindByTopic do
  before do
    @list1 = create(:subscriber_list, tags: { format: { any: %w[raib_report], } })
    @list2 = create(:subscriber_list, tags: { topics: { any: ["environmental-management/boating"], } })
    @list3 = create(:subscriber_list, tags: {
      topics: {
        any: [
        "environmental-management/boating",
        "environmental-management/sailing",
        "environmental-management/swimming"
        ],
      }
    })
  end

  it "finds lists where at least one value is in the topic tags" do
    expect(described_class.new.call(topic: 'environmental-management/sailing')).to eq [@list3]
  end
end
