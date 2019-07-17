package com.sputnikmessenger.sputnik_audio_recorder

import android.media.MediaRecorder
import android.util.Log
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import kotlin.collections.HashMap

class SputnikAudioRecorderPlugin : MethodCallHandler {

    companion object {
        private var channel: MethodChannel? = null;
        @JvmStatic
        fun registerWith(registrar: Registrar) {
            channel = MethodChannel(registrar.messenger(), "com.sputnikmessenger.sputnik_audio_recorder")
            channel!!.setMethodCallHandler(SputnikAudioRecorderPlugin())
        }
    }


    private var mediaRecorder = HashMap<String, MediaRecorder>();

    override fun onMethodCall(call: MethodCall, result: Result) {

        when (call.method) {
            "startRecording" -> startRecording(call, result)
            "stopRecording" -> stopRecording(call, result)
            "pauseRecording" -> pauseRecording(call, result)
            "resumeRecording" -> resumeRecording(call, result)
            "disposeRecorder" -> disposeRecorder(call, result)
            "disposeAll" -> disposeAll(call, result)
            "getMaxAmplitude" -> getMaxAmplitude(call, result)
            else -> {
                result.notImplemented()
            }
        }
    }


    private fun startRecording(call: MethodCall, result: Result) {

        Log.d("audio", "start");
        val handle = handleFrom(call);
        val recorder = this.mediaRecorder.getOrPut(handle, defaultValue = { MediaRecorder() })
        recorder.reset()

        recorder.setAudioSource(call.argument<Int>("audioSource")!!)
        recorder.setOutputFormat(call.argument<Int>("outputFormat")!!)
        recorder.setOutputFile(call.argument<String>("outputFile")!!)
        recorder.setAudioEncoder(call.argument<Int>("audioEncoder")!!)


        if (call.hasArgument("audioChannels")) {
            recorder.setAudioChannels(call.argument<Int>("audioChannels")!!)
        }
        if (call.hasArgument("audioEncodingBitRate")) {
            recorder.setAudioEncodingBitRate(call.argument<Int>("audioEncodingBitRate")!!)
        }
        if (call.hasArgument("audioSamplingRate")) {
            recorder.setAudioSamplingRate(call.argument<Int>("audioSamplingRate")!!)
        }
        if (call.hasArgument("maxDuration")) {
            recorder.setMaxDuration(call.argument<Int>("maxDuration")!!)
        }
        if (call.hasArgument("maxFileSize")) {
            recorder.setMaxFileSize(call.argument<Long>("maxFileSize")!!)
        }
        recorder.setOnErrorListener(MediaRecorder.OnErrorListener { mr, what, extra ->
            recorder.reset()
            val map = HashMap<String, String>()
            map["handle"] = handle
            map["what"] = what.toString()
            map["extra"] = extra.toString()
            channel!!.invokeMethod("onError", map)
        })
        recorder.setOnInfoListener(MediaRecorder.OnInfoListener { mr, what, extra ->
            val map = HashMap<String, Int>()
            map["what"] = what
            map["extra"] = extra
            channel!!.invokeMethod("onInfo", map)
            val limitReached = what == MediaRecorder.MEDIA_RECORDER_INFO_MAX_DURATION_REACHED
                    || what == MediaRecorder.MEDIA_RECORDER_INFO_MAX_FILESIZE_REACHED;
            if (limitReached) {
                recorder.reset()
                channel!!.invokeMethod("onLimitReached", handle)
            }
        })
        recorder.prepare()
        recorder.start()
        result.success(handle)
    }


    private fun stopRecording(call: MethodCall, result: Result) {
        Log.d("audio", "stop");
        val handle = handleFrom(call);
        val recorder = mediaRecorder[handle];
        if (recorder != null) {
            recorder.stop()
            recorder.reset()
            result.success(handle)
        } else {
            result.error("handle_not_found", "recorder to stop with handle $handle not found", null);
        }
    }

    private fun pauseRecording(call: MethodCall, result: Result) {
        Log.d("audio", "pause");
        val handle = handleFrom(call);
        val recorder = mediaRecorder[handle];
        if (recorder != null) {
            recorder.pause();
            result.success(handle)
        } else {
            result.error("handle_not_found", "recorder to pause with handle $handle not found", null);
        }
    }

    private fun resumeRecording(call: MethodCall, result: Result) {
        Log.d("audio", "resume");
        val handle = handleFrom(call);
        val recorder = mediaRecorder[handle];
        if (recorder != null) {
            recorder.resume()
            result.success(handle)
        } else {
            result.error("handle_not_found", "recorder to resume with handle $handle not found", null);
        }
    }

    private fun disposeRecorder(call: MethodCall, result: Result) {
        Log.d("audio", "dispose");
        val handle = handleFrom(call);
        val recorder = mediaRecorder[handle];
        if (recorder != null) {
            recorder.reset()
            recorder.release()
            mediaRecorder.remove(handle);
            result.success(handle)
        } else {
            result.error("handle_not_found", "recorder to dispose with handle $handle not found", null);
        }
    }

    private fun disposeAll(call: MethodCall, result: Result) {
        Log.d("audio", "disposeAll");
        mediaRecorder.values.forEach { recorder ->
            recorder.reset()
            recorder.release()
        }
        mediaRecorder.clear();
        result.success("ok")
    }

    private fun getMaxAmplitude(call: MethodCall, result: Result) {
        Log.d("audio", "getMaxAmplitude");
        val handle = handleFrom(call);
        val recorder = mediaRecorder[handle];

        if (recorder != null) {
            result.success(recorder.maxAmplitude);
        } else {
            result.error("handle_not_found", "recorder to get max amplitude for with handle $handle not found", null);
        }
    }

    private fun handleFrom(call: MethodCall): String {
        return call.argument<String>("handle")!!
    }

}
