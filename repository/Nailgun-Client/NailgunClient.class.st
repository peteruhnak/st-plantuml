Class {
	#name : #NailgunClient,
	#superclass : #Object,
	#instVars : [
		'socketStream',
		'workingDirectory',
		'address',
		'port'
	],
	#classVars : [
		'ARG',
		'CMD',
		'ENV',
		'EXIT',
		'HEADER_SIZE',
		'STDERR',
		'STDIN',
		'STDIN_EOF',
		'STDIN_START',
		'STDOUT',
		'WCD'
	],
	#category : #'Nailgun-Client-Client'
}

{ #category : #'class initialization' }
NailgunClient class >> initialize [
	HEADER_SIZE := 5.
	ARG := $A.
	ENV := $E.
	WCD := $D.
	CMD := $C.
	STDIN := $0.
	STDOUT := $1.
	STDERR := $2.
	STDIN_START := $S.
	STDIN_EOF := $..
	EXIT := $X
]

{ #category : #accessing }
NailgunClient >> address [
	^ address ifNil: [ address := 'localhost' ]
]

{ #category : #accessing }
NailgunClient >> address: anAddress [
	address := anAddress
]

{ #category : #'api - running' }
NailgunClient >> asyncRun: aCommand arguments: arguments stdin: aString do: aTwoArgBlock [
	| response stdout stderr |
	[ self connect.
	arguments do: [ :each | self sendArgument: each ].
	self sendWorkingDirectory.
	self sendCommand: aCommand.
	self sendStdin: aString.
	response := self readUntilExit.
	stdout := String
		withAll: ((response select: [ :each | each first = STDOUT ]) flatCollect: #second).
	stderr := String
		withAll: ((response select: [ :each | each first = STDERR ]) flatCollect: #second).
	self disconnect.
	aTwoArgBlock value: stdout value: stderr ] fork
]

{ #category : #socket }
NailgunClient >> connect [
	socketStream := SocketStream openConnectionToHostNamed: self address port: self port.
	socketStream binary
]

{ #category : #'instance creation' }
NailgunClient >> createChunk: aType payload: aPayload [
	^ (aPayload size asByteArrayOfSize: 4) , {aType charCode} , aPayload asByteArray
]

{ #category : #socket }
NailgunClient >> disconnect [
	socketStream close.
	socketStream := nil
]

{ #category : #socket }
NailgunClient >> ensureConnected [
	self isConnected
		ifFalse: [ self connect ]
]

{ #category : #testing }
NailgunClient >> isConnected [
	^ socketStream isConnected
]

{ #category : #testing }
NailgunClient >> isValidType: aType [
	^ {STDOUT.
	STDERR.
	EXIT.
	STDIN_START} includes: aType
]

{ #category : #accessing }
NailgunClient >> port [
	^ port ifNil: [ port := 2113 ]
]

{ #category : #accessing }
NailgunClient >> port: aPort [
	port := aPort
]

{ #category : #receiving }
NailgunClient >> readChunk [
	| chunk size type payload result |
	chunk := socketStream next: 5.
	size := (chunk first: 4) asInteger.
	type := (chunk at: 5) asCharacter.
	self assert: [ self isValidType: type ].
	"sanity check"
	self assert: [ size < 4096 ].
	payload := socketStream next: size.
	self assert: [ payload size = size ].
	result := {type.
	String withAll: (payload asArray collect: #asCharacter).
	payload.
	chunk}.
	^ result
]

{ #category : #receiving }
NailgunClient >> readUntilExit [
	| responses shouldEnd |
	responses := OrderedCollection new.
	shouldEnd := false.
	[ | chunk |
	chunk := self readChunk.
	responses add: chunk.
	shouldEnd := chunk first = EXIT ] doWhileFalse: [ shouldEnd ].
	^ responses
]

{ #category : #'api - running' }
NailgunClient >> run: aCommand arguments: arguments [
	| response |
	self connect.
	arguments do: [ :each | self sendArgument: each ].
	self sendWorkingDirectory.
	self sendCommand: aCommand.
	response := self readUntilExit.
	self disconnect.
	^ response
]

{ #category : #'api - running' }
NailgunClient >> run: aCommand arguments: arguments stdin: aString [
	| response stdout stderr rest |
	self connect.
	arguments do: [ :each | self sendArgument: each ].
	self sendWorkingDirectory.
	self sendCommand: aCommand.
	self sendStdin: aString.
	response := self readUntilExit.
	stdout := String
		withAll: ((response select: [ :each | each first = STDOUT ]) flatCollect: #second).
	stderr := String
		withAll: ((response select: [ :each | each first = STDERR ]) flatCollect: #second).
	rest := response
		reject: [ :each | 
			{STDOUT.
			STDERR} includes: each first ].
	self disconnect.
	^ {stdout.
	stderr.
	rest}
]

{ #category : #sending }
NailgunClient >> send: aType payload: aPayload [
	| chunk |
	self assert: [ self isConnected ].
	chunk := self createChunk: aType payload: aPayload.
	self sendChunk: chunk
]

{ #category : #sending }
NailgunClient >> sendArgument: anArgument [
	self send: ARG payload: anArgument
]

{ #category : #sending }
NailgunClient >> sendChunk: aChunk [
	socketStream
		nextPutAll: aChunk;
		flush
]

{ #category : #sending }
NailgunClient >> sendCommand: aCommand [
	self send: CMD payload: aCommand
]

{ #category : #sending }
NailgunClient >> sendStdin: aPayload [
	(self split: aPayload withUnixLineEndings size: 512)
		do: [ :each | self send: STDIN payload: each ].
	self send: STDIN_EOF payload: ''
]

{ #category : #sending }
NailgunClient >> sendWorkingDirectory [
	self sendWorkingDirectory: workingDirectory
]

{ #category : #sending }
NailgunClient >> sendWorkingDirectory: aWorkingDirectory [
	self send: WCD payload: aWorkingDirectory fullName
]

{ #category : #socket }
NailgunClient >> socketStream [
	^ socketStream
]

{ #category : #socket }
NailgunClient >> socketStream: aStream [
	socketStream := aStream
]

{ #category : #utility }
NailgunClient >> split: aCollection size: aSize [
	| groups |
	groups := OrderedCollection new.
	aCollection readStream in: [ :s | [ s atEnd ] whileFalse: [ groups add: (s next: aSize) ] ].
	^ groups asArray
]

{ #category : #accessing }
NailgunClient >> workingDirectory [
	^ workingDirectory
]

{ #category : #accessing }
NailgunClient >> workingDirectory: aWorkingDirectory [
	workingDirectory := aWorkingDirectory
]
