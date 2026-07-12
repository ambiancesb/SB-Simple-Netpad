#include "speech_to_text_windows_plugin.h"

#include <flutter/plugin_registrar_windows.h>

namespace speech_to_text_windows {

void SpeechToTextWindowsPlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows *registrar) {
  // Intentionally empty: no COM init, no SAPI. Voice is mobile-only in Netpad.
  registrar->AddPlugin(std::make_unique<SpeechToTextWindowsPlugin>());
}

SpeechToTextWindowsPlugin::SpeechToTextWindowsPlugin() = default;

SpeechToTextWindowsPlugin::~SpeechToTextWindowsPlugin() = default;

}  // namespace speech_to_text_windows
