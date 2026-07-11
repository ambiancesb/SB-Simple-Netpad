#ifndef RUNNER_STORE_PLUGIN_H_
#define RUNNER_STORE_PLUGIN_H_

#include <flutter/binary_messenger.h>
#include <flutter/method_channel.h>
#include <flutter/standard_method_codec.h>

#include <memory>

#include <windows.h>

// Registers the Microsoft Store durable IAP method channel.
void RegisterStorePlugin(flutter::BinaryMessenger* messenger, HWND hwnd);

#endif  // RUNNER_STORE_PLUGIN_H_
