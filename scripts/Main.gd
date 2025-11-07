extends Node

signal native_response(action: String, data: Dictionary, tag: String)

var native_bridge: Object = null

func _ready() -> void:
    if Engine.has_singleton("NativeBridge"):
        native_bridge = Engine.get_singleton("NativeBridge")

        if native_bridge.has_signal("native_response"):
            native_bridge.connect("native_response", Callable(self, "_on_native_response"))
            
        print("NativeBridge singleton found.")
    else:
        push_warning("NativeBridge plugin not found. Native calls will be skipped on this platform.")

    _example_calls()

func _example_calls() -> void:
    # Example echo call
    call_native("echo", {
        "message": "Hello from Godot",
        "value": 42,
        "nested": {
            "key": "value"
        }
    }, "tag_echo_1")
    
    # Example unknown action (to test error handling)
    call_native("unknown_action", {"test": "data"}, "tag_unknown_1")
    
    # Another echo example with different data
    call_native("echo", {
        "player_name": "John",
        "score": 1000
    }, "tag_echo_2")

func call_native(action: String, data: Dictionary = {}, tag: String = "") -> void:
    if native_bridge == null:
        push_warning("NativeBridge not available, ignoring action: %s" % action)
        return

    if native_bridge.has_method("call_native"):
        print("[Godot] Calling native - action: %s, tag: %s" % [action, tag])
        native_bridge.call("call_native", action, data, tag)
    else:
        push_warning("NativeBridge has no method 'call_native'.")

func _on_native_response(action: String, data: Dictionary, tag: String) -> void:
    print("[Godot] Received response - action: %s, tag: %s, data: %s" % [action, tag, str(data)])
    emit_signal("native_response", action, data, tag)
