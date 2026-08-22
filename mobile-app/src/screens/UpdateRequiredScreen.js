import React, { useState } from 'react';
import { View, Text, TouchableOpacity, StyleSheet, ActivityIndicator, Alert, Platform } from 'react-native';
import * as FileSystem from 'expo-file-system';
import * as IntentLauncher from 'expo-intent-launcher';

export default function UpdateRequiredScreen({ apkUrl, notes }) {
  const [downloading, setDownloading] = useState(false);
  const [progress, setProgress] = useState(0);

  async function downloadAndInstall() {
    setDownloading(true);
    setProgress(0);
    try {
      const fileUri = FileSystem.cacheDirectory + 'taskflow-update.apk';

      const downloadResumable = FileSystem.createDownloadResumable(
        apkUrl,
        fileUri,
        {},
        (downloadProgress) => {
          const pct = downloadProgress.totalBytesWritten / downloadProgress.totalBytesExpectedToWrite;
          setProgress(pct);
        }
      );

      const result = await downloadResumable.downloadAsync();
      if (!result || !result.uri) throw new Error('download_failed');

      if (Platform.OS === 'android') {
        const contentUri = await FileSystem.getContentUriAsync(result.uri);
        await IntentLauncher.startActivityAsync('android.intent.action.VIEW', {
          data: contentUri,
          flags: 1, // FLAG_GRANT_READ_URI_PERMISSION
          type: 'application/vnd.android.package-archive',
        });
      }
    } catch (e) {
      Alert.alert(
        'Could not download update',
        "Something went wrong downloading the update. Check your connection and try again."
      );
    }
    setDownloading(false);
  }

  return (
    <View style={styles.wrap}>
      <Text style={styles.title}>Update Required</Text>
      <Text style={styles.sub}>
        A newer version of TaskFlow is available and this version can no longer be used.
        Tap below to download and install it — just one confirmation and you're done.
      </Text>
      {notes ? <Text style={styles.notes}>{notes}</Text> : null}

      <TouchableOpacity style={styles.btn} onPress={downloadAndInstall} disabled={downloading}>
        {downloading ? (
          <View style={{ alignItems: 'center' }}>
            <ActivityIndicator color="#fff" />
            <Text style={styles.progressText}>{Math.round(progress * 100)}%</Text>
          </View>
        ) : (
          <Text style={styles.btnText}>Download & Install</Text>
        )}
      </TouchableOpacity>

      <Text style={styles.hint}>
        Android will ask you to confirm the install once — tap "Install" when prompted. If asked
        to allow installs from this source, tap Allow and then try again.
      </Text>
    </View>
  );
}

const styles = StyleSheet.create({
  wrap: { flex: 1, backgroundColor: '#0F172A', justifyContent: 'center', alignItems: 'center', padding: 28 },
  title: { fontSize: 24, fontWeight: '800', color: '#fff', marginBottom: 14, textAlign: 'center' },
  sub: { color: '#CBD5E1', textAlign: 'center', fontSize: 15, lineHeight: 22, marginBottom: 14 },
  notes: { color: '#94A3B8', textAlign: 'center', fontSize: 13, marginBottom: 24, fontStyle: 'italic' },
  btn: { backgroundColor: '#2563EB', borderRadius: 12, paddingVertical: 15, paddingHorizontal: 28, marginTop: 8, minWidth: 220, alignItems: 'center' },
  btnText: { color: '#fff', fontWeight: '700', fontSize: 16 },
  progressText: { color: '#fff', fontWeight: '700', fontSize: 13, marginTop: 6 },
  hint: { color: '#64748B', textAlign: 'center', fontSize: 12, marginTop: 20, lineHeight: 18 },
});
