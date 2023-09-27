# Logger
This is a simple implementation of a logger with levels, that supports breadCrumbs.

### Basic Usage
1. Create an instance of it.
```
var logger = new Logger();
```
2. Print text to terminal.
```
logger.log("hello world");
```
### Toogle between showing log
1. Can also provide additional inputs within a single call.
```
logger.log("hidden log", {flags: ~LOGGER_FLAGS.SHOW})
```
2. Fluent interface.
```
logger.log("hello", {level: LOGGER_LEVELS.INFO}).log("world", {level: "END"})
```
# Cleanup
When no longer needed can cleanup.
```
logger.cleanup();
```
