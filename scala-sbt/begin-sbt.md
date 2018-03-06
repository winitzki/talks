# SBT for Scala development

## Basic SBT concepts

### What SBT does

SBT is used to:

- configure the build
- use REPL to inspect and debug the build configuration
- run the code or tests
- run a Scala REPL with project's classpath
- publish compiled JARs

### Configuring the build 

The build configuration specifies:

- Source files for main / test code
- Scala compiler version and options
- JVM options for `run` and `test` commands
- Code dependencies on 3rd party libraries
    - Where to download these libraries (artifactory resolvers)
    - Version overrides, dependency exclusions
    - Main code vs. test code dependencies
- Build steps that generate new source files
- Options for building application JARs ("assembly")
- Artifactory URLs and options for publishing compiled JARs

### build.sbt is Scala code

- The build configuration is a Scala object

- Typically, uses 3 files:

```
/build.sbt
/project/build.properties
/project/plugins.sbt
```

- Can add other `.sbt` or `.scala` files into `/project/`.

#### Advantages

Using Scala as configuration language provides extreme flexibility

- `sbt test` could...
    - run tests using a custom testing framework
    - prepare and upload XLSX spreadsheet to Confluence
    - launch missiles
- we can refactor code to avoid repetitive configs
- we can use 3rd party Scala or Java libraries
    - SBT provides a rich library (IO, processes, HTTP)
- we have IntelliJ support for `build.sbt` itself
- we can write our own "SBT plugins" to provide custom settings/tasks/commands

#### Disadvantages

- Configuration _needs to be compiled first_
    - what configures the configuration?
        - default Scala version 2.10
        - `/project/project`
    - build is slower because of additional compilation steps
- Errors in `build.sbt` are harder to debug
    - (IntelliJ cannot load anything)
- SBT's library DSL has a steep learning curve
    - `assemblyMergeStrategy in assembly ~= (old => { ...`

## Learn by example

- We need to learn by example...
    - because there are just too many conventions and functions
- SBT is written in Scala
    - discover new settings by exploring SBT source code via IntelliJ!

- Cut-and-paste code is mostly okay with `build.sbt`
    - as long as you copy from similar projects

### How does SBT configure all that?

SBT provides a rich library with predefined functions

- Settings: the values we assign
- Tasks: the commands we run

Example settings:

```scala
val scalaVersion: SettingKey[String]
val publishArtifact: SettingKey[Boolean]
val libraryDependencies: SettingKey[Seq[ModuleID]]
```

Example commands:

```scala
val compile = TaskKey[Analysis]
val doc = TaskKey[File]
val packageBin = TaskKey[File]

```

### Specify the version of SBT

The `project/build.properties` file should contain this line:

```
sbt.version = 0.13.16

```

- The latest version of SBT is `1.0.2`...
    - but it is not yet stable enough for us

### Example `build.sbt`: Single-project build

By default, the project directory is `.`

```scala
scalaVersion := "2.12.4"

crossScalaVersions := Seq("2.11.11", "2.12.4")

name := "my-app"

version := "1.0.0"

libraryDependencies ++= Seq(
  "org.scalatest" %% "scalatest" % "3.0.4" % Test,
  "org.apache.poi" % "poi-ooxml" % "3.14",
  "org.apache.hadoop" % "hadoop-core" % "latest.integration"
)

```

### File layout: Single-project build

```
/build.sbt
/project/build.properties

/project/target

/src/main/scala/...
/src/main/resources/...
/src/test/scala/...
/src/test/resources/...

/target/...

```

- The `target/` directories are created automatically
- `sbt clean` will delete all `target/` subdirectories

### Example `build.sbt`: many subprojects

- Subprojects are `my_app`, `my_lib`, and `my_client`

```scala

val common = Seq(
  version := "1.0.0",
  scalaVersion := "2.12.4",
  crossScalaVersions := Seq("2.11.11", "2.12.4")
)

// Root subproject: will not publish JARs, only aggregate other subprojects.
// So e.g. `sbt test` will run tests in the aggregated subprojects.
lazy val hello_root = (project in file("."))
  .settings(common)
  .settings(
    publishArtifact := false
  )
  .aggregate(my_app, my_client, my_lib)

// main standalone app subproject, source code in ./myapp/
lazy val my_app = (project in file("myapp"))
  .settings(common)
  .settings(
    name := "my-app", // my-app_2.12-1.0.0.jar
    libraryDependencies ++= Seq(
      "org.scalatest" %% "scalatest" % "3.0.4" % Test,
      "org.apache.poi" % "poi-ooxml" % "3.14",
      "org.apache.hadoop" % "hadoop-core" % "latest.integration"
    )
  ).dependsOn(my_lib)

// client subproject, source code in ./myclient/
lazy val my_client = (project in file("myclient"))
  .settings(common)
  .settings(
    name := "my-client", // my-client_2.12-1.0.0.jar
    libraryDependencies ++= Seq(
      "org.scalatest" %% "scalatest" % "3.0.4" % Test,
      ...
    )
  ).dependsOn(my_lib)

// library subproject, source code in ./mylib/
lazy val my_lib = (project in file("mylib"))
  .settings(common)
  .settings(
    name := "my-lib", // my-lib_2.12-1.0.0.jar
    libraryDependencies ++= Seq(
      "org.scalatest" %% "scalatest" % "3.0.4" % Test,
      ...
    )
  )

```

### File layout: many subprojects

- Subprojects are in directories `myapp`, `mylib`, and `myclient`

```
/build.sbt
/project/build.properties
/project/target

/target

/myapp/src/main/scala/...
/myapp/src/main/resources/...
/myapp/src/test/scala/...
/myapp/src/test/resources/...

/myapp/target/...

/myclient/src/main/scala/...
/myclient/src/test/scala/...

/myclient/target/...

/mylib/src/main/scala/...
/mylib/src/main/java/...
/mylib/src/test/scala/...

/mylib/target/...

```

- Note: Java files must be in `.../main/java/`
    - Java files are compiled together with Scala in the same JAR

## What goes into `project/plugins.sbt`?

It is the configuration needed to compile your main `build.sbt`

- SBT plugins used in the build (coverage, scalastyle, etc.)
- Libraries needed to compile and run the main `build.sbt`
    - libraries for source code generation (e.g. protobuf)
- Artifactory resolvers needed to resolve these plugins and libraries

## Basic SBT tasks

- `sbt update` - verify/download all dependencies
- `sbt compile` - compile the main code
- `sbt test:compile` - compile the main code and the test code
- `sbt run` - run the `main` method of the `App` object
- `sbt test` - run all tests
- `sbt publishLocal` - package JARs and publish to `$HOME/.ivy2/local`
- `sbt publishSigned` - package JARs and publish to some artifactory

- `sbt assembly` - package the application JAR

- `sbt clean` - delete all compiled and generated files

## Basic SBT settings

- version and options for the Scala compiler
    - `scalaVersion`, `scalacSettings`
- dependencies on libraries
    - `libraryDependencies`, `dependencyOverrides`, `dependsOn()`, `Test`, `%`, `%%`
- JAR artifact names and where to publish the JARs
    - `version`, `name`, `publishTo`

Settings can be subproject-specific:

```scala
version := (version in mySubproject).value
```

- Must use `.value` or `.taskValue` when on the right side of `:=`, `+=`, `++=`, `~=`

Example:

```scala
resourceGenerators in Compile += Def.task {
      val res: File = (resourceDirectory in Compile).value
      val externalPath: Classpath = (externalDependencyClasspath in Compile).value
      bundleInstall(res, externalPath) // Returns a Seq[File]
    }.taskValue
```

Another example:

```scala
libraryDependencies ++= (if (scalaBinaryVersion.value == "2.10") Seq(
    ... // library dependencies for Scala 2.10
    )
    else Seq(
    ... // dependencies for Scala versions above 2.10
    ))
```

- All settings are evaluated when tasks are run on a project, not at definition site

- Semantics of `:=` is similar to assignment:

```scala
project(...).settings(
  name := "my-project",
  name := "real-project-name" // this is the actual value used
)
```

- Too much to cover here; we learn from examples and `stackoverflow`

## Anatomy of a JAR

- JAR is a zip file with extra metadata (secure signing)

- There are five kinds of JAR files:
    - application JAR (have `main` method, can run with `java -jar file.jar`, all dependencies included)
    - library JAR (no `main` method, just one library's classes, no dependencies included in JAR)
    - library JARs with some 3rd party dependencies included in JAR (trouble!!!)
        - example of this: `mockito-all-1.9.5.jar` 
    - source JAR (Java/Scala files only)
    - documentation JAR (HTML files only)

- A typical library JAR contains three kinds of files:
    - Java class files: `*.class`
    - Resource files: default config files, data files
    - Build-time information, licenses, etc.

- Working with JARs: `unzip -l file.jar`, etc.
    - each `.class` file is in its package directory
        - `import org.apache.zookeeper.server.ZooTrace` in code
        - `org/apache/zookeeper/server/ZooTrace.class` in JAR

- Example of JAR contents:

```
META-INF/MANIFEST.MF
META-INF/maven/org.javolution/javolution-core-java/pom.properties
META-INF/maven/org.javolution/javolution-core-java/pom.xml
javax/realtime/RealtimeThread.class
javolution/context/AbstractContext.class
...
```

- Assembling an application JAR:
    - compile the application into its `.class`
    - download all library JARs and unpack them too
    - copy all resource files, e.g. `src/main/resources/blah/file` into `./blah/file`
    - also copy all resource files from library JARs
    - gather all unpacked files under one directory, deduplicate
    - add `META-INF/MANIFEST.MF`
    - zip everything into one big JAR
- All this is done by the SBT assembly plugin automatically
    - the deduplication rules must be specified manually (`assemblyMergeStrategy`)


## Project dependencies

- Most projects use code from other projects or other libraries
   - Since we are using open source libraries, IntelliJ can navigate to the full source code of every dependency

There are two kinds of dependencies:

- `libraryDependencies`: use published third-party libraries
    - the library JARs are downloaded from "artifactories" such as Maven
- `.dependsOn()`: use code from another subproject in the same `build.sbt`

Main differences:

- library dependencies:
    - specific library version or range
    - uses artifactory or local cache
- subproject dependencies:
    - always depends on current version
    - does not use AF or local cache
    - dependent and depending subprojects must be published at the same version

When to use (with in-house code):

- subproject dependencies: for code actively developed in sync
- library dependencies: for stable or unrelated code


### Library dependencies

- Prefer managed libraries (`libraryDependencies ++= ...`) to unmanaged (JARs in `lib/` subdirectory)
    - See [SBT documentation on library management](http://www.scala-sbt.org/1.0/docs/Library-Management.html)

- Discover what versions of libraries are available:
    - Look at [Official Maven site](http://search.maven.org/) only!
        - Do not use `MVNRepository.com`, it is not current with Maven
    - Determine what version you want to use
        - Is this version very recent with no newer patches? Suspicious.
        - Is this version very old with no newer patches? Either very stable, or suspicious.
        - Does it have Scala 2.11 / 2.12 versions published?

- Add your required dependencies to your project's settings:

```scala
libraryDependencies ++= Seq(
   "org.scalatest" %% "scalatest" % "3.0.4" % Test,
   "org.apache.poi" % "poi-ooxml" % "3.14"
)

```

- The Scala dependencies must be `%%`, the Java dependencies `%`
    - The `%%` inserts a Scala binary version suffix, e.g. `_2.11`
    - Note: Scala version can be overridden, e.g. `sbt ++2.10.6 compile`
        - Do not hard-code Scala binary version, use `scalaBinaryVersion.value` instead

### Main code vs. test code

- What is this `% Test`?
    - it's called a **classifier**
    - most often you will have no classifier or just a `Test` classifier
    - `% Test` is the same as `% "test"` and the same as `% "test->compile"`
    - **test dependencies** are libraries used only when running tests
    - other code that depends on your code (i.e. downstream from you) usually needs neither your tests or your test dependencies
        - if really necessary, your test code can be published as a "test JAR"

- Typically each library will also have its own **main** code and **test** code
    - `src/main/scala/...` and `/src/test/scala/...`

There are four possibilities:

1. Our main code depends on the library's main code: no classifier needed
2. Our test code depends on the library's main code: `% Test` or `% "test"` or `% "test->compile"`
3. Our test code depends on the library's test code: Really? `% "test->test"
4. Our main code depends on the library's test code: Really now?? `% "compile->test"`

Classifiers can be combined: `% "compile->compile;test->test"`

Recommended practices:

- Make sure your test dependencies are marked with `% Test` to avoid leaking them downstream
    - Usual culprits: `scalatest`, `mockito`, and in-house test utilities libraries
- As a rule, do not depend on the test code of other projects! (Test code is usually quite unstable.)
    - If you need common "test utilities", make that a separate library project and use it as a `% Test` dependency (Case 2)

### Getting out of "JAR hell" I

Symptoms of "JAR hell":

- code compiles but does not run because "cannot find class / method"
- code compiles, tests run, but cannot assemble application JAR due to "deduplication" errors
- code compiles, tests run, but assembled application JAR does not run because "cannot find class / method"

Most frequent cause of "JAR hell":

- Transitive dependencies that declare different incompatible versions of the same library
    - SBT will choose the latest of these versions; other versions will be "evicted"
        - We usually don't depend on this library directly and don't even know about its existence
        - Incompatible API changes occurred, but the code is not aware of this due to dependency eviction
    - Use `dependencyOverrides ++= Set(...)` and/or `exclude()` to force a non-latest version and evict others

Example of this:

- Our code depends on Library A and Library B
- Library A depends on org.libraryX 1.0.0
- Library B depends on org.libraryX 1.1.0
    - There is a breaking change in some method or class, for example:
        - org.libraryX version 1.0.0: `def myMethod(a: Int)`
        - org.libraryX version 1.1.0: `def myMethod(a: Int, b: Boolean = true)`
    - org.libraryX 1.0.0 is evicted, but library A does not know about that and breaks
- Your code and/or the code in Library A may need to be changed to fix this problem!

Use the `sbt-dependency-graph` plugin to figure this out

- Most useful command: `whatDependsOn org.apache.zookeeper zookeeper 3.4.5`
- Second most useful command: `sbt dependencyGraph > depgraph.txt`
    - Redirecting to file because the output is _very_ verbose and redundant
    - `sbt dependencyBrowseGraph` will open a graphical browser

### Getting out of "JAR hell" II

Less frequent reasons for "JAR hell":

- Some library JARs contain classes from third libraries
    - `slf4j-over-log4j` contains some of the same classes as `log4j`
    - `mockito-all` contains its dependencies `hamcrest-core` and `objenesis`

- Some library depends on other third-party libraries that are incompatible with our other dependencies
    - But we don't need any functionality of those other libraries!
    - Use `exclude()`, `excludeAll`, `excludeDependencies` to [remove transitive dependencies](http://www.scala-sbt.org/1.0/docs/Library-Management.html#Exclude+Transitive+Dependencies)

- Some library has changed name and not only version
    - `woodstox-core-asl` 4.x was continued as `woodstox-core` 5.x
    - use `exclude()`

- Use the SBT plugin `sbt-duplicates-finder`
    -  discovers Java classes that are duplicated but have different contents
        - sure sign of trouble!

- Go through your `$HOME/.ivy2/cache` and find out which JARs have the problematic classes
    - `find $HOME/.ivy2/cache -name \*jar | while read f; do unzip -l $f | grep -q 'Problem.class' && echo $f; done `
    - IntelliJ can decompile `.class` files or JARs that you drop into the file tree of any project

For assembling the application JAR:

- Use `assemblyMergeStrategy` carefully
    - some files require `concat` (e.g. `*.properties` or Akka's `reference.conf`) 
    - strategies `first` and `last` are nondeterministic (which library is first or last?)
    - prefer to use `exclude()` or `dependencyOverride` if that works

## General recommendations about using SBT

- Organize your project in subprojects by directory - e.g. server, client, common library, test utilities, etc.
    - there should not be any circular dependencies between subprojects!
    - use aggregator-only subprojects to control builds

- In `build.sbt`, make `val`s with common settings and reuse them in subprojects
    - make simple libraries or SBT plugins to hold collections of common settings, e.g. AF resolvers, scalac options

- Useful SBT plugins: scalastyle, scoverage, dependency-graph, sbt-duplicates-finder, WartRemover, acyclic

- Start SBT and do not quit it
    - working within the same SBT session is faster than starting SBT each time
    - do `reload` when `build.sbt` or `plugins.sbt` change
    - other than that, just do `compile`, `test:compile`, `testOnly`, `test`, `run`, `project mySubproject`
