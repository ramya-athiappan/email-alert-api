require 'json'

class NotificationWorker
  include Sidekiq::Worker

  def perform(notification_json)
    notification = JSON.parse(notification_json).with_indifferent_access

    lists = SubscriberList.with_at_least_one_tag_of_each_type(tags: notification[:tags])

    Rails.logger.info "--- Sending email to GovDelivery ---"
    Rails.logger.info "subject: '#{notification[:subject]}'"
    Rails.logger.info "tags: '#{notification[:tags]}'"
    Rails.logger.info "matched #{lists.count} lists in GovDelivery: [#{lists.map(&:gov_delivery_id).join(', ')}]"
    Rails.logger.info "notification_json: #{notification_json}"
    Rails.logger.info "--- End email to GovDelivery ---"

    EmailAlertAPI.services(:gov_delivery).send_bulletin(
      lists.map(&:gov_delivery_id),
      notification[:subject],
      notification[:body]
    )

    Rails.logger.info "Email '#{notification[:subject]}' sent"
  end
end
