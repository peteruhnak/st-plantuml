"
Baseline for https://github.com/peteruhnak/st-plantuml
"
Class {
	#name : #BaselineOfPlantUML,
	#superclass : #BaselineOf,
	#category : #BaselineOfPlantUML
}

{ #category : #baselines }
BaselineOfPlantUML >> baseline: spec [
	<baseline>
	spec
		for: #common
		do: [ 
			spec package: 'Nailgun-Client'.
			spec package: 'PlantUML' with: [spec requires: 'Nailgun-Client'].
			spec group: 'default' with: #('PlantUML') ]
]
