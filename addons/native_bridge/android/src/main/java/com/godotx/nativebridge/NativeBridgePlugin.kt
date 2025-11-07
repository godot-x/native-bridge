package com.example.nativebridge

import android.util.Log
import org.godotengine.godot.Godot
import org.godotengine.godot.GodotPlugin
import org.godotengine.godot.annotation.RegisterClass
import org.godotengine.godot.annotation.RegisterFunction
import org.godotengine.godot.annotation.Signal
import org.godotengine.godot.Dictionary
import org.json.JSONObject

@RegisterClass
class NativeBridgePlugin(godot: Godot) : GodotPlugin(godot) {

    @Signal
    fun nativeResponse(action: String, data: Dictionary, tag: String) {
    }

    override fun getPluginName(): String {
        return "NativeBridge"
    }

    @RegisterFunction
    fun callNative(action: String, data: Dictionary, tag: String) {
        Log.d("NativeBridge", "Received action: $action, tag: $tag")
        
        when (action) {
            "echo" -> handleEcho(action, data, tag)
            else -> handleUnknownAction(action, data, tag)
        }
    }

    private fun handleEcho(action: String, data: Dictionary, tag: String) {
        // Echo simply returns the same data
        sendResponse(action, data, tag)
    }

    private fun handleUnknownAction(action: String, data: Dictionary, tag: String) {
        val errorData = Dictionary()
        errorData["error"] = "unknown_action"
        errorData["message"] = "Unknown action: $action"
        sendResponse(action, errorData, tag)
    }

    @RegisterFunction
    fun sendResponse(action: String, data: Dictionary, tag: String) {
        Log.d("NativeBridge", "Send action: $action, tag: $tag")
        emitSignal("native_response", action, data, tag)
    }
}
