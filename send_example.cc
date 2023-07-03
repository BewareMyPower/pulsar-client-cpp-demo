#include <pulsar/Client.h>

#include "log_utils.h"
using namespace pulsar;

int main(int argc, char* argv[]) {
  Client client("pulsar://localhost:6650");

  Producer producer;
  Result result =
      client.createProducer("persistent://public/default/my-topic", producer);
  if (result != ResultOk) {
    LOG_ERROR("Error creating producer: " << result);
    return -1;
  }

  // Send synchronously
  for (int i = 0; i < 10000; i++) {
    Message msg = MessageBuilder().setContent("content").build();
    Result res = producer.send(msg);
    if (res != ResultOk) {
      LOG_ERROR("Failed to send " << i << res);
      break;
    }
    // NOTE: It might stuck, if we logged for each message, it would work well.
    if (i % 100 == 99) {
      LOG_INFO("XYZ " << i << " done");
    }
  }

  client.close();
  return 0;
}
