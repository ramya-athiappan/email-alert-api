class FindExactMatch
  def initialize(query_field: :tags, scope: SubscriberList)
    raise ArgumentError.new("query_field must be `:tags` or `:links`") unless %i{tags links}.include?(query_field)

    @query_field = query_field.to_sym
    @scope = scope
  end

  def call(query_hash)
    return [] unless query_hash.present?

    subscriber_lists = subscriber_lists_where_all_keys_present(query_hash)

    subscriber_lists.select do |subscriber_list|
      subscriber_list_tags_or_links = subscriber_list.send(@query_field) # send ensures the keys are symbols

      subscriber_list_tags_or_links.keys.all? do |key|
        Array(query_hash[key][:any]).sort == Array(subscriber_list_tags_or_links[key][:any]).sort
      end
    end
  end

private

  # Return all SubscriberLists which are marked with all of the same link types
  # as those requested.  For example, if `links` is:
  #
  #     {"topics": [...], "organisations": [...]}
  #
  # then this returns all lists which have any "topics" AND "organisations"
  # links.
  def subscriber_lists_where_all_keys_present(query_hash)
    # This uses array equality to check if the JSON object
    # contains all the specified keys.
    @scope.where("ARRAY(SELECT json_object_keys(#{@query_field})) = Array[:keys]",
      keys: query_hash.keys,)
  end
end
