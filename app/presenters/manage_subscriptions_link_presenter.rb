class ManageSubscriptionsLinkPresenter
  def initialize(address:)
    @address = address
  end

  def self.call(*args)
    new(*args).call
  end

  def call
    "[View and manage your subscriptions](#{url})"
  end

  private_class_method :new

private

  attr_reader :address

  def url
    PublicUrlService.authenticate_url(address: address)
  end
end
