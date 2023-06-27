// https://github.com/apache/pulsar/pull/7819
#include <pulsar/Client.h>

#include "close_guard.h"
#include "log_utils.h"
using namespace pulsar;

int main(int argc, char* argv[]) {
  Client client{"pulsar://127.0.0.1:6650"};
  CloseGuard<Client> client_guard{client};

  const std::string topic = "my-topic";
  Producer producer;
  if (auto result = client.createProducer(topic, producer);
      result != ResultOk) {
    LOG_ERROR("Failed to create producer: " << result);
    return 1;
  }

  producer.send(MessageBuilder().setContent("hello").build());

  for (int i = 0; i < 100; i++) {
    Consumer consumer;
    if (auto result = client.subscribe(topic, "sub", consumer);
        result != ResultOk) {
      LOG_ERROR(i << " Failed to subscribe: " << result);
      return 2;
    }
    consumer.seekAsync(MessageId::earliest(), [](auto result) {
      LOG_INFO("Seek to earliest: " << result);
    });
    if (auto result = consumer.close(); result != ResultOk) {
      LOG_ERROR("Failed to close: " << result);
    }
  }
  return 0;
}
