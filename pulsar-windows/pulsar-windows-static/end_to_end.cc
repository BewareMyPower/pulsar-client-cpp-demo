#define PULSAR_STATIC
#include <pulsar/Client.h>
using namespace pulsar;

int main() {
  const char* service_url = "pulsar://localhost:6650";
  const char* topic = "my-topic";
  Client client(service_url);
  Producer producer;
  auto result = client.createProducer(topic, producer);
  if (result != ResultOk) {
    std::cerr << "Failed to create producer: " << result << std::endl;
    return 1;
  }
  Consumer consumer;
  result = client.subscribe(topic, "sub", consumer);
  if (result != ResultOk) {
    std::cerr << "Failed to subscribe: " << result << std::endl;
    return 2;
  }
  MessageId id;
  producer.send(MessageBuilder().setContent("msg").build(), id);
  std::cout << "send to " << id << std::endl; 
  Message msg;
  consumer.receive(msg);
  std::cout << "received " << msg.getDataAsString() << " from "
            << msg.getMessageId() << std::endl;
  consumer.acknowledge(msg);
  client.close();
}
