#ifndef NATIVE_BRIDGE_H
#define NATIVE_BRIDGE_H

// Godot C++ bindings
#include <godot_cpp/classes/object.hpp>
#include <godot_cpp/variant/string.hpp>
#include <godot_cpp/variant/dictionary.hpp>
#include <godot_cpp/core/class_db.hpp>

namespace godot {

class NativeBridge : public Object {
    GDCLASS(NativeBridge, Object);

    static NativeBridge *singleton;

protected:
    static void _bind_methods();

public:
    NativeBridge();
    ~NativeBridge();

    static NativeBridge *get_singleton();

    // Main interface - called from Godot to native
    void call_native(const String &action, const Dictionary &data, const String &tag);
    
    // Called from native side to send response back to Godot
    void send_response(const String &action, const Dictionary &data, const String &tag);

private:
    // Action handlers
    void handle_echo(const String &action, const Dictionary &data, const String &tag);
    void handle_unknown_action(const String &action, const Dictionary &data, const String &tag);
};

} // namespace godot

#endif // NATIVE_BRIDGE_H
