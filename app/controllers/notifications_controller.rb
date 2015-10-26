class NotificationsController < ApplicationController
  def create
    NotificationWorker.perform_async(notification_params)

    respond_to do |format|
      format.json { render json: {message: "Notification queued for sending"}, status: 202 }
    end
  end

private

  def notification_params
    params.slice(:subject, :body, :from_address_id, :urgent, :header, :footer)
      .merge(tags: params.fetch(:tags, {}))
      .merge(links: params.fetch(:links, {}))
  end
end
