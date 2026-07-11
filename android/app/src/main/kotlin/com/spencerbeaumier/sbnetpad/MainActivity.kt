package com.spencerbeaumier.sbnetpad

import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import android.net.ConnectivityManager
import android.net.Network
import android.net.NetworkCapabilities
import android.net.wifi.WifiManager
import android.os.Build
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.net.Inet4Address

class MainActivity : FlutterActivity() {
    private var multicastLock: WifiManager.MulticastLock? = null
    private var connectivityCallback: ConnectivityManager.NetworkCallback? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "acquireMulticastLock" -> {
                    acquireMulticastLock()
                    result.success(null)
                }
                "hasLanTransport" -> {
                    result.success(hasLanTransport())
                }
                "getLanIpv4" -> {
                    result.success(getLanIpv4())
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onStart() {
        super.onStart()
        acquireMulticastLock()
        requestNearbyWifiPermissionIfNeeded()
        registerConnectivityCallback()
    }

    override fun onStop() {
        unregisterConnectivityCallback()
        super.onStop()
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray,
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode != NEARBY_WIFI_PERMISSION_REQUEST) return
        acquireMulticastLock()
        notifyDartNetworkingChanged()
    }

    private fun registerConnectivityCallback() {
        if (connectivityCallback != null) return
        val cm = applicationContext.getSystemService(Context.CONNECTIVITY_SERVICE)
            as? ConnectivityManager ?: return
        connectivityCallback = object : ConnectivityManager.NetworkCallback() {
            override fun onAvailable(network: Network) {
                notifyDartNetworkingChanged()
            }

            override fun onLost(network: Network) {
                notifyDartNetworkingChanged()
            }
        }
        cm.registerDefaultNetworkCallback(connectivityCallback!!)
    }

    private fun unregisterConnectivityCallback() {
        val cm = applicationContext.getSystemService(Context.CONNECTIVITY_SERVICE)
            as? ConnectivityManager ?: return
        connectivityCallback?.let { cm.unregisterNetworkCallback(it) }
        connectivityCallback = null
    }

    private fun notifyDartNetworkingChanged() {
        runOnUiThread {
            flutterEngine?.dartExecutor?.binaryMessenger?.let { messenger ->
                MethodChannel(messenger, CHANNEL).invokeMethod("networkChanged", null)
            }
        }
    }

    private fun hasLanTransport(): Boolean {
        val cm = applicationContext.getSystemService(Context.CONNECTIVITY_SERVICE)
            as? ConnectivityManager ?: return false
        for (network in cm.allNetworks) {
            val caps = cm.getNetworkCapabilities(network) ?: continue
            if (caps.hasTransport(NetworkCapabilities.TRANSPORT_WIFI) ||
                caps.hasTransport(NetworkCapabilities.TRANSPORT_ETHERNET)
            ) {
                return true
            }
        }
        return false
    }

    private fun getLanIpv4(): String? {
        val cm = applicationContext.getSystemService(Context.CONNECTIVITY_SERVICE)
            as? ConnectivityManager ?: return null
        for (network in cm.allNetworks) {
            val caps = cm.getNetworkCapabilities(network) ?: continue
            val isLan = caps.hasTransport(NetworkCapabilities.TRANSPORT_WIFI) ||
                caps.hasTransport(NetworkCapabilities.TRANSPORT_ETHERNET)
            if (!isLan) continue
            val props = cm.getLinkProperties(network) ?: continue
            for (link in props.linkAddresses) {
                val host = link.address
                if (host !is Inet4Address || host.isLoopbackAddress) continue
                val ip = host.hostAddress ?: continue
                if (isPrivateLanIpv4(ip)) return ip
            }
        }
        return null
    }

    private fun isPrivateLanIpv4(ip: String): Boolean {
        val parts = ip.split('.')
        if (parts.size != 4) return false
        val octets = parts.mapNotNull { it.toIntOrNull() }
        if (octets.size != 4) return false
        val (a, b, _, _) = octets
        if (a == 10) return true
        if (a == 172 && b in 16..31) return true
        if (a == 192 && b == 168) return true
        return false
    }

    private fun acquireMulticastLock() {
        val wifi = applicationContext.getSystemService(Context.WIFI_SERVICE)
            as? WifiManager ?: return
        if (multicastLock?.isHeld == true) return
        multicastLock = wifi.createMulticastLock("netpadMdns").apply {
            setReferenceCounted(true)
            acquire()
        }
    }

    private fun requestNearbyWifiPermissionIfNeeded() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) return
        if (ContextCompat.checkSelfPermission(
                this,
                Manifest.permission.NEARBY_WIFI_DEVICES,
            ) == PackageManager.PERMISSION_GRANTED
        ) {
            return
        }
        ActivityCompat.requestPermissions(
            this,
            arrayOf(Manifest.permission.NEARBY_WIFI_DEVICES),
            NEARBY_WIFI_PERMISSION_REQUEST,
        )
    }

    companion object {
        private const val CHANNEL = "com.spencerbeaumier.sbnetpad/networking"
        private const val NEARBY_WIFI_PERMISSION_REQUEST = 1001
    }
}
