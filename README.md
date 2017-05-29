libkeybinder bindings for D
===========================
libkeybinder is a GTK+ library for setting global keybindings. These are keybindings that apply
across the whole desktop, even if the application is not in focus.


Get it
------
Add `"keybinder": "~>0.1.0"` to your dub.json.


Using with GTK+
---------------
libkeybinder is designed to work with GTK+:

```D
import gtk.lotsOfStuff;
static import keybinder;

void main()
{
	auto app = new Application();
	app.addOnActivate(delegate void(GioApplication a)
	{
		keybinder.init();
		keybinder.bindGlobal("<Super>f", () {
			writeln("<Super>f was pressed");
		});
	});
}
```


Using without GTK+
------------------
Using this library without GTK+ (for instance, using DLangUI) requires a bit of extra work:

```D
import std.stdio, core.thread, core.time;
static import keybinder;

void main()
{
	keybinder.initNoGTK();
	keybinder.bindGlobal("<Super>f", () {
		writeln("<Super>f was pressed");
	});
	while (true)
	{
		keybinder.poll();
		sleep(dur!"msecs"(50));
	}
}
```

This still requires GTK+, but you don't have to deal with it yourself.

However, if you're not using GTK+, why not use WebFreak001's XKeyBinD?
