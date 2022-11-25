#include <pulsar/Client.h>
using namespace pulsar;

int main(int argc, char* argv[]) {
  if (argc < 2) {
    std::cerr << "Usage: " << argv[0] << " service-url" << std::endl;
    return 1;
  }
  Client client(argv[1]);
  const std::string topic = "basic_e2e_example";
  Producer producer;
  {
    auto result = client.createProducer(topic, producer);
    if (result != ResultOk) {
      return 1;
    }
  }
  Consumer consumer;
  {
    auto result = client.subscribe(topic, "sub", consumer);
    if (result != ResultOk) {
      return 2;
    }
  }

  for (int i = 0; i < 10; i++) {
    producer.send(
        MessageBuilder().setContent("msg-" + std::to_string(i)).build());
  }
  for (int i = 0; i < 10; i++) {
    Message msg;
    auto result = consumer.receive(msg, 1000);
    if (result != ResultOk) {
      std::cerr << "Failed to receive " << i << ": " << result << std::endl;
      break;
    }
    std::cout << "Received " << msg.getDataAsString() << " from "
              << msg.getMessageId() << std::endl;
    consumer.acknowledge(msg);
  }

  client.close();
  return 0;
}
