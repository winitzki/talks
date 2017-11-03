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
    - Where to download these libraries
    - Version overrides, dependency exclusions
    - Main code vs. test code dependencies
- Build steps that generate new source files
- Options for building application JARs ("assembly")
- Artifactory URLs and options for publishing compiled JARs

### build.sbt is Scala code

- The build configuration is a Scala object

- At the minimum, uses 2 files:

```
/build.sbt
/project/build.properties
```

#### Advantages

Using Scala as configuration language privides extreme flexibility

- `sbt test` could...
    - prepare and upload XLSX spreadsheet to Confluence
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
- Errors in `build.sbt` are hard to debug
    - (IntelliJ cannot load anything)
- SBT's library DSL has a steep learning curve
    - `assemblyMergeStrategy in assembly ~= (old => { ...`

## Learn by example

The `project/build.properties` file should always contain this:

```
sbt.version = 0.13.16
```

### Example `build.sbt`: Single-project build

```
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

```

val common = Seq(
  version := "1.0.0",
  scalaVersion := "2.12.4",
  crossScalaVersions := Seq("2.11.11", "2.12.4")
)

lazy val hello_root = (project in file("."))
  .settings(common)
  .settings(
    publishArtifact := false
  )
  .aggregate(my_app, my_client)
  
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

lazy val my_client = (project in file("myclient"))
  .settings(common)
  .settings(
    name := "my-client", // my-client_2.12-1.0.0.jar
    libraryDependencies ++= Seq(
      "org.scalatest" %% "scalatest" % "3.0.4" % Test,
      ...
    )
  ).dependsOn(my_lib)

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
/mylib/src/test/scala/...

/mylib/target/...

```

## Basic SBT commands

- `sbt update` - verify/download all dependencies
- `sbt compile` - compile the main code
- `sbt test:compile` - compile the main code and the test code
- `sbt run` - run the `main` method of the `App` object
- `sbt test` - run all tests
- `sbt publishLocal` - package JARs and publish to `$HOME/.ivy2/local`

- `sbt clean` - delete all compiled and generated files

## Dependencies

There are two kinds of dependencies:

- `libraryDependencies`: use Maven published third-party libraries
- `.dependsOn()`: use code from another subproject in the same `build.sbt`

Main differences:

- library dependencies:
    - specific library version or range
    - uses artifactory or local cache
- subproject dependencies:
    - always depends on current version
    - does not use AF or local cache
    - subproject dependency must be published at the same version

When to use (with in-house code):

- subproject dependencies: for code actively developed in sync
- library dependencies: for stable or unrelated code

To discover what versions of libraries are available:

- Look at [Official Maven site](http://search.maven.org/) only!
    - Do not use `MVNRepository.com`, it is not current with Maven
