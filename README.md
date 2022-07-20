# MSVC + MSBuild + Wine + Docker

A hacky solution to get MSVC + MSBuild and friends to work in a Linux docker container.

It does crazy things when creating the container such as spawning a headless Weston session with XWayland.
But when it's just running, it should just work(tm).

There are other MSVC + Wine projects out there, but this is the best one because it works.
