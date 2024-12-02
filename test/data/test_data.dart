import 'dart:convert';

final androidConfigString = jsonEncode({
  'authorities': [
    {
      'type': 'AAD',
      'audience': {'type': 'AzureADandPersonalMicrosoftAccount'},
      'default': true,
    }
  ],
  'authorization_user_agent': 'DEFAULT',
  'multiple_clouds_supported': false,
  'broker_redirect_uri_registered': false,
  'http': {'connect_timeout': 10000, 'read_timeout': 30000},
  'logging': {
    'pii_enabled': false,
    'log_level': 'WARNING',
    'logcat_enabled': false,
  },
  'shared_device_mode_supported': false,
  'account_mode': 'MULTIPLE',
  'browser_safelist': [
    {
      'browser_package_name': 'com.android.chrome',
      'browser_signature_hashes': ['aB1cD2eF3gH4iJ5kL6-mN7oP8qR=='],
      'browser_use_customTab': true,
      'browser_version_lower_bound': '45',
    },
    {
      'browser_package_name': 'com.android.chrome',
      'browser_signature_hashes': ['cD2eF3gH4iJ5kL6mN7-oP8qR9sT=='],
      'browser_use_customTab': false,
    },
    {
      'browser_package_name': 'org.mozilla.firefox',
      'browser_signature_hashes': ['eF3gH4iJ5kL6mN7oP8-qR9sT0uV=='],
      'browser_use_customTab': false,
    },
    {
      'browser_package_name': 'org.mozilla.firefox',
      'browser_signature_hashes': ['gH4iJ5kL6mN7oP8qR9-sT0uV1wX=='],
      'browser_use_customTab': true,
      'browser_version_lower_bound': '57',
    },
    {
      'browser_package_name': 'com.sec.android.app.sbrowser',
      'browser_signature_hashes': ['iJ5kL6mN7oP8qR9sT0-uV1wX2yZ=='],
      'browser_use_customTab': true,
      'browser_version_lower_bound': '4.0',
    },
    {
      'browser_package_name': 'com.sec.android.app.sbrowser',
      'browser_signature_hashes': ['kL6mN7oP8qR9sT0uV1-wX2yZ3aB=='],
      'browser_use_customTab': false,
    },
    {
      'browser_package_name': 'com.cloudmosa.puffinFree',
      'browser_signature_hashes': ['mN7oP8qR9sT0uV1wX2-yZ3aB4dE='],
      'browser_use_customTab': false,
    },
    {
      'browser_package_name': 'com.duckduckgo.mobile.android',
      'browser_signature_hashes': ['S5Av4...jAi4Q=='],
      'browser_use_customTab': false,
    },
    {
      'browser_package_name': 'com.explore.web.browser',
      'browser_signature_hashes': ['BzDzB...YHCag=='],
      'browser_use_customTab': false,
    },
    {
      'browser_package_name': 'com.ksmobile.cb',
      'browser_signature_hashes': ['lFDYx...7nouw=='],
      'browser_use_customTab': false,
    },
    {
      'browser_package_name': 'com.microsoft.emmx',
      'browser_signature_hashes': ['Ivy-R...A6fVQ=='],
      'browser_use_customTab': false,
    },
    {
      'browser_package_name': 'com.opera.browser',
      'browser_signature_hashes': ['FIJ3I...jWJWw=='],
      'browser_use_customTab': false,
    },
    {
      'browser_package_name': 'com.opera.mini.native',
      'browser_signature_hashes': ['TOTyH...mmUYQ=='],
      'browser_use_customTab': false,
    },
    {
      'browser_package_name': 'mobi.mgeek.TunnyBrowser',
      'browser_signature_hashes': ['RMVoXgjjgyjjmbj4578fcbkyyQ=='],
      'browser_use_customTab': false,
    },
    {
      'browser_package_name': 'org.mozilla.focus',
      'browser_signature_hashes': ['L72dT...q0oYA=='],
      'browser_use_customTab': false,
    }
  ],
});