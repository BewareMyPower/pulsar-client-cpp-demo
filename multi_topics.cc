#include <pulsar/Client.h>
#include <time.h>

#include <atomic>
#include <chrono>
#include <future>
#include <random>
#include <thread>

#include "log_utils.h"
using namespace pulsar;

struct ClientGuard {
  ClientGuard(Client& client) : client_(client) {}
  ~ClientGuard() { client_.close(); }

 private:
  Client& client_;
};

int main(int argc, char* argv[]) {
  if (argc > 1 && std::string(argv[1]) == "-h") {
    std::cerr << "Usage: " << argv[0]
              << " <running-seconds> <number-producers>\n"
                 "Default:\n"
                 "  running-seconds: 3\n"
                 "  number-producers: 10"
              << std::endl;
    return 0;
  }
  const long kSleepSeconds = (argc > 1) ? std::stol(argv[1]) : 3;
  const int kNumProducers = (argc > 2) ? std::stoi(argv[2]) : 10;

  Client client{"pulsar://127.0.0.1:6650"};
  ClientGuard client_guard{client};
  std::vector<Producer> producers{static_cast<size_t>(kNumProducers)};
  auto topic_base = "my-topic-" + std::to_string(time(nullptr)) + "-";
  LOG_INFO("Use topic base: " << topic_base);

  std::atomic_int num_producers_created{0};
  std::promise<Result> producers_created_promise;
  for (int i = 0; i < kNumProducers; i++) {
    client.createProducerAsync(
        topic_base + std::to_string(i),
        [i, kNumProducers, &num_producers_created, &producers_created_promise,
         &producers](Result result, const auto& producer) {
          if (result != ResultOk) {
            LOG_ERROR("Failed to create producer for " << i << ": " << result);
            producers_created_promise.set_value(result);
            return;
          }
          producers[i] = producer;
          if (++num_producers_created == kNumProducers) {
            producers_created_promise.set_value(ResultOk);
          }
        });
  }
  if (auto result = producers_created_promise.get_future().get();
      result != ResultOk) {
    return 1;
  }

  std::random_device rd;
  std::mt19937 gen{rd()};
  std::uniform_int_distribution<int> distrib{0, kNumProducers - 1};
  int index = distrib(gen);
  const auto topic = topic_base + std::to_string(index);
  LOG_INFO("Select " << topic_base << index << " to consume");
  Consumer consumer;
  ConsumerConfiguration conf;
  conf.setMessageListener([](Consumer consumer, const Message& msg) {
    LOG_INFO("Received " << msg.getDataAsString() << " from "
                         << msg.getMessageId());
    consumer.acknowledge(msg);
  });
  if (auto result = client.subscribe(topic, "sub", conf, consumer);
      result != ResultOk) {
    LOG_ERROR("Failed to subscribe " << topic << ": " << result);
    return 2;
  }

  std::atomic_bool running{true};
  std::vector<std::future<Result>> futures;
  for (size_t i = 0; i < kNumProducers; i++) {
    auto& producer = producers[i];
    futures.emplace_back(
        std::async(std::launch::async, [&running, &producer, i]() {
          int suffix = 0;
          while (running) {
            auto msg = MessageBuilder()
                           .setContent("msg-" + std::to_string(i) + "-" +
                                       std::to_string(suffix))
                           .build();
            if (auto result = producer.send(msg); result != ResultOk) {
              return result;
            }
            if (!running) {
              break;
            }
            std::this_thread::sleep_for(std::chrono::milliseconds(100));
          }
          return ResultOk;
        }));
  }

  std::this_thread::sleep_for(std::chrono::seconds(kSleepSeconds));
  running = false;
  for (size_t i = 0; i < kNumProducers; i++) {
    if (auto result = futures[i].get(); result != ResultOk) {
      LOG_INFO("Producer " << i << " exited with " << result);
    }
  }

  return 0;
}
