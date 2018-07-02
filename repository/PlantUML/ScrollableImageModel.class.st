"
I am a Spec model showing an image (a Form) with scrollbars if the image is larger than the viewport.
"
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
	morph widget scroller submorphs copy
		do: [ :each | morph widget scroller removeMorph: each ].
	morph widget scroller addMorph: aForm asMorph.
	morph widget scrollValue: 0 @ 0.
	morph widget scrollBy: 0 @ 0.
	morph widget hideOrShowScrollBars
]

{ #category : #accessing }
ScrollableImageModel >> initialExtent [
	^ 100 @ 100
]

{ #category : #initialization }
ScrollableImageModel >> initializeWidgets [
	morph := DraggableScrollPane new
		hResizing: #spaceFill;
		vResizing: #spaceFill;
		asSpecAdapter
]

{ #category : #accessing }
ScrollableImageModel >> morph [
	^ morph
]
