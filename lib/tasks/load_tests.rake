require "benchmark"
require "load_tester"

def benchmark_and_print
  results = Benchmark.measure do
    yield
  end

  puts results
end

namespace :load_tests do
  desc "Run a load test of the DeliveryRequestWorker by triggering requests"
  task :delivery_request_worker, [:number] => :environment do |_t, args|
    benchmark_and_print do
      LoadTester.test_delivery_request_worker(args[:number].to_i)
    end
  end

  desc "Run a load test of the EmailGenerationWorker by triggering requests"
  task :email_generation_worker, [:number] => :environment do |_t, args|
    benchmark_and_print do
      LoadTester.test_email_generation_worker(args[:number].to_i)
    end
  end

  desc "Run a load test of the SubscriptionContentWorker by triggering requests"
  task :subscription_content_worker, [:number] => :environment do |_t, args|
    benchmark_and_print do
      LoadTester.test_subscription_content_worker(args[:number].to_i)
    end
  end

  desc "Run a load test of the NotificationHandlerService by triggering requests"
  task :notification_handler_service, [:number] => :environment do |_t, args|
    benchmark_and_print do
      LoadTester.test_notification_handler_service(args[:number].to_i)
    end
  end
end