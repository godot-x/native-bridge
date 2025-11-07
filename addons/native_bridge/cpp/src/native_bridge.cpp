#include "native_bridge.h"

#include <godot_cpp/classes/engine.hpp>
#include <godot_cpp/variant/utility_functions.hpp>
#include <godot_cpp/variant/variant.hpp>
#include <godot_cpp/classes/json.hpp>

using namespace godot;

// Forward declarations for iOS
#ifdef __APPLE__
#include <TargetConditionals.h>
#if TARGET_OS_IOS
extern "C" {
    void ios_native_bridge_call_native(const char *action, const char *data_json, const char *tag);
}
#endif
#endif

NativeBridge *NativeBridge::singleton = nullptr;

NativeBridge::NativeBridge() {
    singleton = this;
}

NativeBridge::~NativeBridge() {
    if (singleton == this) {
        singleton = nullptr;
    }
}

NativeBridge *NativeBridge::get_singleton() {
    return singleton;
}

void NativeBridge::_bind_methods() {
    ClassDB::bind_method(D_METHOD("call_native", "action", "data", "tag"), &NativeBridge::call_native);
    ClassDB::bind_method(D_METHOD("send_response", "action", "data", "tag"), &NativeBridge::send_response);
    
    ADD_SIGNAL(MethodInfo("native_response", 
        PropertyInfo(Variant::STRING, "action"),
        PropertyInfo(Variant::DICTIONARY, "data"),
        PropertyInfo(Variant::STRING, "tag")
    ));
}

void NativeBridge::call_native(const String &action, const Dictionary &data, const String &tag) {
    UtilityFunctions::print(String("[NativeBridge] call_native - action: ") + action + ", tag: " + tag);
    
#ifdef __APPLE__
#include <TargetConditionals.h>
#if TARGET_OS_IOS
    // On iOS, delegate to Objective-C++ implementation
    Ref<JSON> json;
    json.instantiate();
    String data_json = json->stringify(data);
    
    ios_native_bridge_call_native(
        action.utf8().get_data(),
        data_json.utf8().get_data(),
        tag.utf8().get_data()
    );
    return;
#endif
#endif
    
    // Default implementation (desktop/other platforms)
    if (action == "echo") {
        handle_echo(action, data, tag);
    } else {
        handle_unknown_action(action, data, tag);
    }
}

void NativeBridge::handle_echo(const String &action, const Dictionary &data, const String &tag) {
    // Echo simply returns the same data
    send_response(action, data, tag);
}

void NativeBridge::handle_unknown_action(const String &action, const Dictionary &data, const String &tag) {
    Dictionary error_data;
    error_data["error"] = "unknown_action";
    error_data["message"] = String("Unknown action: ") + action;
    send_response(action, error_data, tag);
}

void NativeBridge::send_response(const String &action, const Dictionary &data, const String &tag) {
    UtilityFunctions::print(String("[NativeBridge] send_response - action: ") + action + ", tag: " + tag);
    emit_signal("native_response", action, data, tag);
}

// C function to be called from iOS
#ifdef __APPLE__
#include <TargetConditionals.h>
#if TARGET_OS_IOS
extern "C" {
    void native_bridge_send_response(const char *action, const char *data_json, const char *tag) {
        NativeBridge *bridge = NativeBridge::get_singleton();
        if (!bridge) {
            return;
        }
        
        String action_str = String(action);
        String tag_str = String(tag);
        String data_json_str = String(data_json);
        
        // Parse JSON string to Dictionary
        Ref<JSON> json;
        json.instantiate();
        Error err = json->parse(data_json_str);
        
        Dictionary data;
        if (err == OK) {
            Variant result = json->get_data();
            if (result.get_type() == Variant::DICTIONARY) {
                data = result;
            }
        }
        
        bridge->send_response(action_str, data, tag_str);
    }
}
#endif
#endif
