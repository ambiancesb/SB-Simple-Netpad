#include "store_plugin.h"

#include <flutter/encodable_value.h>

#include <memory>
#include <optional>
#include <string>

#include <shobjidl.h>
#include <winrt/Windows.Foundation.Collections.h>
#include <winrt/Windows.Foundation.h>
#include <winrt/Windows.Services.Store.h>

namespace {

constexpr wchar_t kProProductId[] = L"netpad_pro";
constexpr char kChannelName[] = "com.spencerbeaumier.sbnetpad/windows_store";

using flutter::EncodableValue;
using flutter::MethodCall;
using flutter::MethodResult;
using winrt::Windows::Foundation::AsyncStatus;
using winrt::Windows::Services::Store::StoreAppLicense;
using winrt::Windows::Services::Store::StoreContext;
using winrt::Windows::Services::Store::StoreLicense;
using winrt::Windows::Services::Store::StoreProduct;
using winrt::Windows::Services::Store::StoreProductQueryResult;
using winrt::Windows::Services::Store::StorePurchaseStatus;

HWND g_hwnd = nullptr;
StoreContext g_store_context{nullptr};

StoreContext GetStoreContext() {
  if (g_store_context == nullptr) {
    g_store_context = StoreContext::GetDefault();
    if (g_hwnd != nullptr) {
      auto init = g_store_context.try_as<::IInitializeWithWindow>();
      if (init) {
        init->Initialize(g_hwnd);
      }
    }
  }
  return g_store_context;
}

bool LicenseHasActivePro(StoreAppLicense const& license) {
  for (auto const& pair : license.AddOnLicenses()) {
    StoreLicense add_on = pair.Value();
    std::wstring sku = add_on.SkuStoreId().c_str();
    if (sku.rfind(kProProductId, 0) == 0 && add_on.IsActive()) {
      return true;
    }
  }
  return false;
}

std::optional<std::string> WideToUtf8(winrt::hstring const& input) {
  if (input.empty()) {
    return std::string();
  }
  const wchar_t* wide = input.c_str();
  int size =
      WideCharToMultiByte(CP_UTF8, 0, wide, -1, nullptr, 0, nullptr, nullptr);
  if (size <= 0) {
    return std::nullopt;
  }
  std::string output(static_cast<size_t>(size - 1), '\0');
  WideCharToMultiByte(CP_UTF8, 0, wide, -1, output.data(), size, nullptr,
                      nullptr);
  return output;
}

// Flutter's UI thread is STA. C++/WinRT forbids blocking `.get()` there
// (debug assert: !is_sta_thread()). Always complete via async callbacks.
void HandleIsPro(std::unique_ptr<MethodResult<EncodableValue>> result) {
  auto shared =
      std::shared_ptr<MethodResult<EncodableValue>>(std::move(result));
  try {
    auto context = GetStoreContext();
    auto op = context.GetAppLicenseAsync();
    op.Completed([shared](auto const& async, AsyncStatus status) {
      try {
        if (status != AsyncStatus::Completed) {
          shared->Success(EncodableValue(false));
          return;
        }
        shared->Success(EncodableValue(LicenseHasActivePro(async.GetResults())));
      } catch (...) {
        shared->Success(EncodableValue(false));
      }
    });
  } catch (...) {
    shared->Success(EncodableValue(false));
  }
}

void HandleGetPrice(std::unique_ptr<MethodResult<EncodableValue>> result) {
  auto shared =
      std::shared_ptr<MethodResult<EncodableValue>>(std::move(result));
  try {
    auto context = GetStoreContext();
    auto kinds = winrt::single_threaded_vector<winrt::hstring>();
    kinds.Append(L"Durable");
    auto op = context.GetAssociatedStoreProductsAsync(kinds);
    op.Completed([shared](auto const& async, AsyncStatus status) {
      try {
        if (status != AsyncStatus::Completed) {
          shared->Error("store_error", "Could not load Microsoft Store price");
          return;
        }
        StoreProductQueryResult query = async.GetResults();
        for (auto const& pair : query.Products()) {
          StoreProduct product = pair.Value();
          if (std::wstring(product.StoreId().c_str()) == kProProductId) {
            auto price = WideToUtf8(product.Price().FormattedPrice());
            if (price.has_value()) {
              shared->Success(EncodableValue(*price));
              return;
            }
          }
        }
        shared->Success(EncodableValue());
      } catch (...) {
        shared->Error("store_error", "Could not load Microsoft Store price");
      }
    });
  } catch (...) {
    shared->Error("store_error", "Could not load Microsoft Store price");
  }
}

void HandlePurchase(std::unique_ptr<MethodResult<EncodableValue>> result) {
  auto shared =
      std::shared_ptr<MethodResult<EncodableValue>>(std::move(result));
  try {
    auto context = GetStoreContext();
    auto op = context.RequestPurchaseAsync(kProProductId);
    op.Completed([shared](auto const& async, AsyncStatus status) {
      try {
        if (status != AsyncStatus::Completed) {
          shared->Error("store_error", "Purchase failed");
          return;
        }
        auto purchase = async.GetResults();
        auto purchase_status = purchase.Status();
        if (purchase_status == StorePurchaseStatus::Succeeded ||
            purchase_status == StorePurchaseStatus::AlreadyPurchased) {
          shared->Success(EncodableValue(true));
          return;
        }
        if (purchase_status == StorePurchaseStatus::NotPurchased) {
          shared->Error("cancelled", "Purchase was cancelled");
          return;
        }
        shared->Error("store_error", "Purchase failed");
      } catch (...) {
        shared->Error("store_error", "Purchase failed");
      }
    });
  } catch (...) {
    shared->Error("store_error",
                  "Microsoft Store purchase requires an MSIX with Store "
                  "identity");
  }
}

void HandleMethodCall(const MethodCall<EncodableValue>& call,
                      std::unique_ptr<MethodResult<EncodableValue>> result) {
  const auto& method = call.method_name();
  if (method == "isPro") {
    HandleIsPro(std::move(result));
  } else if (method == "getPrice") {
    HandleGetPrice(std::move(result));
  } else if (method == "purchase") {
    HandlePurchase(std::move(result));
  } else {
    result->NotImplemented();
  }
}

}  // namespace

void RegisterStorePlugin(flutter::BinaryMessenger* messenger, HWND hwnd) {
  g_hwnd = hwnd;
  auto channel = std::make_unique<flutter::MethodChannel<EncodableValue>>(
      messenger, kChannelName, &flutter::StandardMethodCodec::GetInstance());
  channel->SetMethodCallHandler(
      [](const MethodCall<EncodableValue>& call,
         std::unique_ptr<MethodResult<EncodableValue>> result) {
        HandleMethodCall(call, std::move(result));
      });
  static auto retained = std::move(channel);
}
