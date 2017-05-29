/** C API for libkeybinder */
module keybinder_c;

alias GDestroyNotify = void*;

alias KeybinderHandler = extern(C) void function(const char* keystring, void* data);

extern(C):

/**
 * Initialize the keybinder library.
 *
 * This function must be called after initializing GTK, before calling any
 * other function in the library. Can only be called once.
 */
void keybinder_init();

/**
 * "Cooked" accelerators use symbols produced by using modifiers such
 * as shift or altgr, for example if "!" is produced by "Shift+1".
 *
 * If cooked accelerators are enabled, use "&lt;Ctrl&gt;exclam" to bind
 * "Ctrl+!" If disabled, use "&lt;Ctrl&gt;&lt;Shift&gt;1" to bind
 * "Ctrl+Shift+1". These two examples are not equal on all keymaps.
 *
 * The cooked accelerator keyvalue and modifiers are provided by the
 * function gdk_keymap_translate_keyboard_state()
 *
 * Cooked accelerators are useful if you receive keystrokes from GTK to bind,
 * but raw accelerators can be useful if you or the user inputs accelerators as
 * text.
 *
 * Default: Enabled. Should be set before binding anything.
 *
 * Args:
 *   use_cooked = if %FALSE disable cooked accelerators
 */
void keybinder_set_use_cooked_accelerators(bool use_cooked);

/**
 * Grab a key combination globally and register a callback to be called each
 * time the key combination is pressed.
 *
 * This function is excluded from introspected bindings and is replaced by
 * keybinder_bind_full.
 *
 * Returns: %TRUE if the accelerator could be grabbed
 *
 * Args:
 *   keystring = an accelerator description (gtk_accelerator_parse() format)
 *   handler   = callback function
 *   user_data = data to pass to @handler
 */
bool keybinder_bind(const char* keystring, KeybinderHandler handler, void* user_data);

/**
 * Grab a key combination globally and register a callback to be called each
 * time the key combination is pressed.
 *
 * Args:
 *   keystring = an accelerator description (gtk_accelerator_parse() format)
 *   handler   = (scope notified):        callback function
 *   user_data = (closure) (allow-none):  data to pass to @handler
 *   notify    = (allow-none):  called when @handler is unregistered
 * Returns: %TRUE if the accelerator could be grabbed
 */
bool keybinder_bind_full(
        const char* keystring,
        KeybinderHandler handler,
        void* user_data,
        GDestroyNotify notify);

/**
 * Unregister all previously bound callbacks for this keystring.
 *
 * Args:
 *   keystring = an accelerator description (gtk_accelerator_parse() format)
 */
void keybinder_unbind_all(const char* keystring);

/**
 * Returns: the current event timestamp in an unspecified format
 */
uint keybinder_get_current_event_time();


