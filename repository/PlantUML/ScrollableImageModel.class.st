Class {
	#name : #ScrollableImageModel,
	#superclass : #ComposableModel,
	#instVars : [
		'morph'
	],
	#category : #PlantUML
}

{ #category : #specs }
ScrollableImageModel class >> defaultSpec [
	^ SpecLayout composed
		add: #morph;
		yourself
]

{ #category : #initialization }
ScrollableImageModel >> form: aForm [
	morph widget scrollTarget: aForm asMorph
]

{ #category : #accessing }
ScrollableImageModel >> initialExtent [
	^ 300 @ 300
]

{ #category : #initialization }
ScrollableImageModel >> initializeWidgets [
	morph := GeneralScrollPane new
		changeScrollerTableLayout;
		"			scrollTarget: f asMorph;"
			layoutFrame: (LayoutFrame fractions: (0 @ 0 corner: 1 @ 1) offsets: (0 @ 25 corner: 0 @ 0));
		extent: 300 @ 300;
		asSpecAdapter
]

{ #category : #accessing }
ScrollableImageModel >> morph [
	^ morph
]
