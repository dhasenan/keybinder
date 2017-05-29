/**
 * keybinder handles binding keys globally on X11 + GTK.
 */
module keybinder;

import keybinder_c;

/**
 * Bind the key binding identified by $(D keys) to the given delegate.
 *
 * Only one callback per key sequence is supported.
 *
 * The callback will be called with a frequency according to the keyboard repeat settings. If a user
 * holds down the relevant key sequence, the callback will be called once, then there will be a
 * delay, then the callback will be called many times.
 */
void bindGlobal(string keys, void delegate() dg)
in
{
    assert(keys !in dgs);
}
body
{
    import std.string : toStringz;
    dgs[keys] = dg;
    keybinder_bind_full(keys.toStringz, &handleKeys, null, null);
}

/**
 * Unbind everything on the given key combination.
 */
void unbindGlobal(string keys)
{
    import std.string : toStringz;
    keybinder_unbind_all(keys.toStringz);
    dgs.remove(keys);
}

/**
 * Initialize global keybinding support.
 *
 * libkeybinder requires you to be running with GTK+ and X11. This init function requires you to
 * have initialized GTK+ yourself; you are responsible for maintaining a GTK+ main loop if you want
 * to receive key events.
 */
void init()
{
    keybinder_init();
}

/**
 * Initialize global keybinding support.
 *
 * libkeybinder requires you to be running with GTK+ and X11. This init function handles GTK+
 * initialization for you. In your program's main loop (or a frequent periodic callback), you must
 * call the poll() function to check whether the key has been pressed.
 */
void initNoGTK()
{
    import core.sys.posix.dlfcn;
    auto d = dlopen("libgtk-3.so".ptr, RTLD_LAZY);
    auto gtk_init = cast(void function())dlsym(d, "gtk_init".ptr);
    gtk_init();
    keybinder_init();
    gtkMainIterationDo = cast(typeof(gtkMainIterationDo))dlsym(d, "gtk_main_iteration_do".ptr);
}

/**
 * Check for new keypresses.
 *
 * If you already have a GTK+ main loop, you should not call this.
 */
void poll()
{
    if (!gtkMainIterationDo)
    {
        throw new Exception(
                "You must call initNoGTK() before calling poll().\n" ~
                "Note that if you have a GTK+ main loop, you don't need to call " ~
                "initNoGTK() or poll(); the GTK+ loop already handles this.");
    }
    gtkMainIterationDo(false);
}

private:

extern (C) bool function(bool) gtkMainIterationDo;

void delegate()[string] dgs;

private extern(C) void handleKeys(const char* keystring, void* data)
{
    import std.string : fromStringz;
    auto k = keystring.fromStringz;
    auto v = k in dgs;
    if (v is null)
    {
        // This shouldn't happen...
        return;
    }
    (*v)();
}
