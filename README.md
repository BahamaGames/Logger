# bgLogger
This is a simple implementation of a logger with levels. This interface can also be used as an internal for other related 'bg' interfaces.

Within the configStruct you can set the logger Tag, and additional level settings.

### Predifined Levels and their configuration
1. INFO   : {show: true, cache: true}
2. DEBUG  : {maxdepth: 4, show: true, cache: true}
3. TRACE  : {show: true, cache: true}
4. WARN   : {maxdepth: 4, show: true, cache: true}
5. ERROR  : {maxdepth: 4, cache: true}
6. FATAL  : {maxdepth: 4, cache: true}

### Basic Useage
1. Create an instance of it.
```
var log = new bgLogger();
```
2. Print text to terminal.
```
log.bgTrace("hello world");
```
### Other useage
1. Can also provide additional inputs within a single call.
```
var name = "RandomUser";
log.bgTrace("hello", name, "Hope everythings good.");
```
2. Chaining methods.
```
log.bgTrace("hello").bgTrace("World").bgTrace("its").bgTrace(12, "oclock in the morning");
```
3. Beautifier:
Special thanks goes to Yal(YellowAfterLife): https://yal.cc/gamemaker-beautifying-json/
```
log.bgTrace("inspecting :").bgBeautify("{\"name\": \"RandomUser\"}");
```
4. Write logs to a file
```
log.bgTrace("Saving logs to file").bgToFile("test.txt");
```
# Cleanup
When done make to sure clean up to prevent memory leak.
```
log.bgLoggerCleanup();
delete log;
```

# Ending
Feel free to addon as long as it meets these requirements. Much would be appreciated
1. Syntax: to prevent conflicts between other projects all non singluar variables must use the prefix bg. Functions should be camelCased, accessible variables should use ```bg_```, none accessible variables ```_bg_``` and local variables ```__bg_```.

2. Maintain the basic principles SOLID A google search: https://www.baeldung.com/solid-principles
