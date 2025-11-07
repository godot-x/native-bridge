#include "native_bridge.h"

#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/godot.hpp>
#include <godot_cpp/classes/engine.hpp>

using namespace godot;

void initialize_native_bridge_module(ModuleInitializationLevel p_level) {
    if (p_level != MODULE_INITIALIZATION_LEVEL_SCENE) {
        return;
    }

    ClassDB::register_class<NativeBridge>();

    NativeBridge *bridge = memnew(NativeBridge);
    Engine::get_singleton()->register_singleton("NativeBridge", bridge);
}

void uninitialize_native_bridge_module(ModuleInitializationLevel p_level) {
    if (p_level != MODULE_INITIALIZATION_LEVEL_SCENE) {
        return;
    }

    NativeBridge *bridge = NativeBridge::get_singleton();
    if (bridge) {
        Engine::get_singleton()->unregister_singleton("NativeBridge");
        memdelete(bridge);
    }
}

extern "C" {

GDExtensionBool GDE_EXPORT native_bridge_library_init(GDExtensionInterfaceGetProcAddress p_get_proc_address, const GDExtensionClassLibraryPtr p_library, GDExtensionInitialization *r_initialization) {
    GDExtensionBinding::InitObject init_obj(p_get_proc_address, p_library, r_initialization);

    init_obj.register_initializer(initialize_native_bridge_module);
    init_obj.register_terminator(uninitialize_native_bridge_module);
    init_obj.set_minimum_library_initialization_level(MODULE_INITIALIZATION_LEVEL_SCENE);

    return init_obj.init();
}

} // extern "C"
