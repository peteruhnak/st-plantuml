Class {
	#name : #NailgunClientTest,
	#superclass : #TestCase,
	#instVars : [
		'client',
		'clientStream',
		'serverStream'
	],
	#category : #'Nailgun-Client-Tests'
}

{ #category : #tests }
NailgunClientTest >> assertChunk: aChunk type: aType payload: aString [
	self assert: (aChunk first: 4) asByteArray asInteger equals: aString size.
	self assert: aChunk fifth equals: aType.
	self assert: (aChunk allButFirst: 5) equals: aString
]

{ #category : #running }
NailgunClientTest >> setUp [
	| listener clientSocket serverSocket |
	listener := Socket newTCP.
	[ listener listenOn: 0 backlogSize: 4.
	clientSocket := Socket newTCP.
	clientSocket connectTo: #[127 0 0 1] port: listener localPort.
	clientSocket waitForConnectionFor: 1.
	self assert: clientSocket isConnected.
	serverSocket := listener waitForAcceptFor: 1.
	self assert: serverSocket isConnected ]
		ensure: [ listener destroy ].
	clientStream := SocketStream on: clientSocket.
	serverStream := SocketStream on: serverSocket.
	client := NailgunClient new socketStream: clientStream
]

{ #category : #running }
NailgunClientTest >> tearDown [
	clientStream ifNotNil: [ clientStream destroy ].
	serverStream ifNotNil: [ serverStream destroy ]
]

{ #category : #tests }
NailgunClientTest >> testCreateChunkPayload [
	| chunk |
	chunk := client createChunk: $0 payload: 'hello'.
	self assert: chunk equals: #[0 0 0 5] , #[48] , #[104 101 108 108 111]
]

{ #category : #'tests - sending' }
NailgunClientTest >> testIsValidType [
	self assert: (client isValidType: $1).
	self assert: (client isValidType: $2).
	self assert: (client isValidType: $X).
	self assert: (client isValidType: $S)
]

{ #category : #'tests - sending' }
NailgunClientTest >> testSendArgument [
	client sendArgument: 'a'.
	self assertChunk: (serverStream next: 6) type: $A payload: 'a'
]

{ #category : #'tests - sending' }
NailgunClientTest >> testSendChunk [
	client sendChunk: #[0 0 0 2 255 50 60].
	self assert: (serverStream next: 7) asByteArray equals: #[0 0 0 2 255 50 60]
]

{ #category : #'tests - sending' }
NailgunClientTest >> testSendCommand [
	client sendCommand: 'a'.
	self assertChunk: (serverStream next: 6) type: $C payload: 'a'
]

{ #category : #'tests - sending' }
NailgunClientTest >> testSendStdin [
	| payload parts |
	payload := (String loremIpsum: 1000) withUnixLineEndings.
	parts := client split: payload size: 512.
	client sendStdin: payload.
	self assertChunk: (serverStream next: 5 + parts first size) type: $0 payload: parts first.
	self assertChunk: (serverStream next: 5 + parts second size) type: $0 payload: parts second
]

{ #category : #'tests - sending' }
NailgunClientTest >> testSendWorkingDirectory [
	client sendWorkingDirectory: FileSystem memory / 'dir'.
	self assertChunk: (serverStream next: 5 + 4) type: $D payload: '/dir'
]

{ #category : #'tests - sending' }
NailgunClientTest >> testSendWorkingDirectoryDefault [
	client workingDirectory: FileSystem memory / 'dir'.
	client sendWorkingDirectory.
	self assertChunk: (serverStream next: 5 + 4) type: $D payload: '/dir'
]

{ #category : #'tests - utility' }
NailgunClientTest >> testSplitSize [
	self assert: (client split: #(1 2 3 4 5) size: 2) equals: #(#(1 2) #(3 4) #(5))
]
