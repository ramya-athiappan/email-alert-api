require_relative "config/env"
require "core_ext"
require "create_topic"
require "ostruct"
require "processable_input_filter"
require "topic_persistence_aspect"
require "ostruct"
require "postgres_adapter"
require "topic_repository"
require "unique_tag_set_filter"

class Application
  def initialize(
    config:,
    storage_adapter: default_storage_adapter,
    gov_delivery_client: default_gov_delivery_client
  )
    @config = config
    @storage_adapter = storage_adapter
    @gov_delivery_client = gov_delivery_client
  end

  def create_topic(context)
    processable_input_filter(
      unique_tag_set_filter(
        topic_persistence_aspect(
          create_topic_service
        )
      )
    ).call(context)
  end

  private

  attr_reader(
    :config,
    :storage_adapter,
    :gov_delivery_client,
  )

  class Topic < OpenStruct
    def to_json(*args, &block)
      to_h.to_json(*args, &block)
    end
  end

  def processable_input_filter(service)
    ->(context) {
      ProcessableInputFilter.new(
        title: context.params.fetch("title", nil),
        tags: context.params.fetch("tags", {}),
        context: context,
        service: service,
      ).call
    }
  end

  def unique_tag_set_filter(service)
    ->(context) {
      UniqueTagSetFilter.new(
        repo: topics_repository,
        tags: context.params.fetch("tags"),
        context: context,
        service: service,
      ).call
    }
  end

  def topic_persistence_aspect(service)
    ->(context) {
      TopicPersistenceAspect.new(
        context: context,
        repo: topics_repository,
        service: service,
      ).call
    }
  end

  def create_topic_service
    ->(context) {
      CreateTopic.new(
        context: context,
        topic_attributes: context.params.slice("title", "tags"),
        gov_delivery_client: gov_delivery_client,
        topic_factory: Topic.method(:new),
      ).call
    }
  end

  def default_gov_delivery_client
    GovDeliveryClient.create_client(GOVDELIVERY_CREDENTIALS)
  end

  def default_storage_adapter
    PostgresAdapter.new(
      config: config,
    )
  end

  def topics_repository
    @topics_repository ||= TopicRepository.new(
      adapter: storage_adapter,
      factory: Topic.method(:new),
    )
  end
end
