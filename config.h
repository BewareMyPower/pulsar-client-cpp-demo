#pragma once

#include <string>

#ifdef INSIDE_DOCKER
#define SERVICE_URL "pulsar://host.docker.internal:6650"
#else
#define SERVICE_URL "pulsar://localhost:6650"
#endif
