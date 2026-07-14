import 'dart:convert';
import 'dart:io';

import 'package:basic_utils/basic_utils.dart';
import 'package:crypto/crypto.dart';
import 'package:netpad/services/tls_secret_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Per-device self-signed TLS identity used to serve `wss://`.
///
/// The certificate and key are generated once and persisted, so the device's
/// certificate fingerprint is stable and can be pinned by peers (TOFU).
/// On iOS/macOS the PEM material lives in the Keychain; elsewhere it uses
/// [SharedPreferences].
class TlsIdentity {
  TlsIdentity._(this.certPem, this.keyPem);

  final String certPem;
  final String keyPem;

  static const _keyCert = 'tls_cert_pem';
  static const _keyKey = 'tls_key_pem';

  late final SecurityContext serverContext = _buildServerContext();

  /// SHA-256 fingerprint of this device's certificate (colon-separated hex).
  late final String fingerprint = certFingerprintFromPem(certPem);

  static Future<TlsIdentity> loadOrCreate(
    SharedPreferences prefs, {
    TlsSecretStore? secretStore,
  }) async {
    final store = secretStore ?? TlsSecretStore.platform(prefs);
    await store.migrateFromPrefsIfNeeded(const [_keyCert, _keyKey]);

    final cert = await store.read(_keyCert);
    final key = await store.read(_keyKey);
    if (cert != null &&
        cert.isNotEmpty &&
        key != null &&
        key.isNotEmpty) {
      return TlsIdentity._(cert, key);
    }
    final generated = _generate();
    await store.write(_keyCert, generated.certPem);
    await store.write(_keyKey, generated.keyPem);
    return generated;
  }

  static TlsIdentity _generate() {
    final pair = CryptoUtils.generateRSAKeyPair(keySize: 2048);
    final priv = pair.privateKey as RSAPrivateKey;
    final pub = pair.publicKey as RSAPublicKey;
    final dn = {'CN': 'SB Simple Netpad'};
    final csr = X509Utils.generateRsaCsrPem(dn, priv, pub);
    final certPem = X509Utils.generateSelfSignedCertificate(priv, csr, 3650);
    final keyPem = CryptoUtils.encodeRSAPrivateKeyToPem(priv);
    return TlsIdentity._(certPem, keyPem);
  }

  SecurityContext _buildServerContext() {
    final context = SecurityContext(withTrustedRoots: false);
    context.useCertificateChainBytes(utf8.encode(certPem));
    context.usePrivateKeyBytes(utf8.encode(keyPem));
    return context;
  }
}

/// SHA-256 fingerprint (colon-separated, uppercase hex) of a PEM certificate.
String certFingerprintFromPem(String pem) =>
    fingerprintFromDer(_derFromPem(pem));

/// SHA-256 fingerprint of raw DER certificate bytes.
String fingerprintFromDer(List<int> der) =>
    _formatFingerprint(sha256.convert(der).bytes);

/// A short, human-comparable form of a fingerprint (first 8 bytes).
String shortFingerprint(String fingerprint) {
  final parts = fingerprint.split(':');
  return parts.take(8).join(':');
}

List<int> _derFromPem(String pem) {
  final base64Body = pem
      .replaceAll(RegExp('-----[^-]+-----'), '')
      // Strip all whitespace (incl. CR/LF) — basic_utils emits CRLF endings,
      // and base64.decode rejects any non-base64 character.
      .replaceAll(RegExp(r'\s'), '');
  return base64.decode(base64Body);
}

String _formatFingerprint(List<int> bytes) => bytes
    .map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase())
    .join(':');
