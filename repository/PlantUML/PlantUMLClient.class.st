Class {
	#name : #PlantUMLClient,
	#superclass : #Object,
	#instVars : [
		'counter',
		'sendCounter',
		'receiveCounter'
	],
	#category : #PlantUML
}

{ #category : #generation }
PlantUMLClient >> generate: aString do: aFormBlock [
	| localCount |
	"counters are used to order received responses and process only the latest one"
	localCount := sendCounter := sendCounter + 1.
	self newClient
		asyncRun: self nailClass
		arguments: {'-tpng' . '-p'}
		stdin: (aString ifEmpty: [ '@startuml' ])
		do: [ :stdout :stderr | 
			receiveCounter < localCount
				ifTrue: [ receiveCounter := localCount.
					aFormBlock value: (ImageReadWriter formFromStream: stdout asByteArray readStream) ] ]
]

{ #category : #generation }
PlantUMLClient >> initialize [
	super initialize.
	sendCounter := 0.
	receiveCounter := 0
]

{ #category : #'accessing - defaults' }
PlantUMLClient >> nailClass [
	^ 'PlantumlNail'
]

{ #category : #'accessing - defaults' }
PlantUMLClient >> nailJarFile [
	^ self repositoryDirectory / 'nail' / 'plantumlnail.jar'
]

{ #category : #generation }
PlantUMLClient >> newClient [
	^ NailgunClient new
		workingDirectory: self workingDirectory;
		yourself
]

{ #category : #'accessing - defaults' }
PlantUMLClient >> plantumlJarFile [
	^ self repositoryDirectory / 'plantuml' / 'plantuml.jar'
]

{ #category : #generation }
PlantUMLClient >> prepareClient [
	self newClient
		run: 'ng-cp' arguments: {self plantumlJarFile fullName};
		run: 'ng-cp' arguments: {self nailJarFile fullName}
]

{ #category : #'accessing - defaults' }
PlantUMLClient >> repositoryDirectory [
	^ (IceRepository registry detect: [ :each | each name = 'st-plantuml' ]) location
]

{ #category : #'accessing - defaults' }
PlantUMLClient >> workingDirectory [
	^ FileLocator imageDirectory asFileReference
]
