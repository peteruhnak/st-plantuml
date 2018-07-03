# ST PlantUML
[![Build Status](https://travis-ci.org/peteruhnak/st-plantuml.svg?branch=master)](https://travis-ci.org/peteruhnak/st-plantuml) [![Coverage Status](https://coveralls.io/repos/github/peteruhnak/st-plantuml/badge.svg)](https://coveralls.io/github/peteruhnak/st-plantuml)

A client to execute PlantUML from Pharo using a nailgun server.

## Installation

```smalltalk
Metacello new
	baseline: 'PlantUML';
	repository: 'github://peteruhnak/st-plantuml/repository';
	load.
```

## Usage

Launching nailgun

```bash
cd nailgun
java -jar nailgun.jar
```

### Editor

```smalltalk
PlantUMLEditor open
```

or use the *PlantUML* world menu.

### Client

To generate an image (a Form instance) use the `generate:do:` method on the client.
Generation is performed asynchronously. Once the result is available, the callback block is executed.

```smalltalk
client := PlantUMLClient new.
client prepareClient.

client generate: 'class Person {
	- group : Group
}

class Group {
	- people : Person[*]
}

Person "people" <--> "group" Group
' do: [ :aForm | aForm inspect ]
```
