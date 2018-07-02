"
I extend ScrollPane to provide scrolling by dragging the image itself.
"
Class {
	#name : #DraggableScrollPane,
	#superclass : #ScrollPane,
	#category : #PlantUML
}

{ #category : #'event handling' }
DraggableScrollPane >> handlesMouseDown: anEvent [
	^ true
]

{ #category : #'event handling' }
DraggableScrollPane >> handlesMouseMove: anEvent [
	^ true
]

{ #category : #'event handling' }
DraggableScrollPane >> handlesMouseUp: anEvent [
	^ true
]

{ #category : #'event handling' }
DraggableScrollPane >> mouseMove: evt [
	evt isDraggingEvent
		ifFalse: [ ^ self ].
	evt hand hasSubmorphs
		ifTrue: [ ^ self ].
	self scrollBy: evt endPoint - evt startPoint.
	evt wasHandled: true
]
