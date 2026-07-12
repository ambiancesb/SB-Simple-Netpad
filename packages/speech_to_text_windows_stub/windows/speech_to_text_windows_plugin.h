#ifndef FLUTTER_PLUGIN_SPEECH_TO_TEXT_WINDOWS_PLUGIN_H_
#define FLUTTER_PLUGIN_SPEECH_TO_TEXT_WINDOWS_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace speech_to_text_windows {

class SpeechToTextWindowsPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  SpeechToTextWindowsPlugin();
  ~SpeechToTextWindowsPlugin() override;

  SpeechToTextWindowsPlugin(const SpeechToTextWindowsPlugin&) = delete;
  SpeechToTextWindowsPlugin& operator=(const SpeechToTextWindowsPlugin&) =
      delete;
};

}  // namespace speech_to_text_windows

#endif  // FLUTTER_PLUGIN_SPEECH_TO_TEXT_WINDOWS_PLUGIN_H_
